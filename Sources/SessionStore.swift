import Foundation
import Combine

struct SensoryProfile: Codable {
    var answers: [Int?] = Array(repeating: nil, count: 10)
    var completed = false
    var wearableLinked = false
    var solutionDate: Date?
}

/// 单个登录账号的档案与每日计划，全部存在本机。
final class SessionStore: ObservableObject {
    let account: String

    @Published private(set) var profile: SensoryProfile
    @Published private(set) var plans: [String: DayPlan]
    @Published private(set) var reportDays: Set<String>
    @Published private(set) var moodScores: [String: Int]

    private let defaults = UserDefaults.standard
    private let profileKey: String
    private let plansKey: String
    private let reportsKey: String
    private let moodsKey: String

    init(account: String) {
        self.account = account
        profileKey = "quietspace.profile.\(account)"
        plansKey = "quietspace.plans.\(account)"
        reportsKey = "quietspace.reports.\(account)"
        moodsKey = "quietspace.moods.\(account)"

        let hadProfile = defaults.data(forKey: profileKey) != nil
        if let data = defaults.data(forKey: profileKey),
           let saved = try? JSONDecoder().decode(SensoryProfile.self, from: data) {
            profile = saved
        } else {
            profile = SensoryProfile()
        }

        if let data = defaults.data(forKey: plansKey),
           let saved = try? JSONDecoder().decode([String: DayPlan].self, from: data) {
            plans = saved
        } else {
            plans = [:]
        }

        if let data = defaults.data(forKey: reportsKey),
           let saved = try? JSONDecoder().decode(Set<String>.self, from: data) {
            reportDays = saved
        } else {
            reportDays = []
        }

        if let data = defaults.data(forKey: moodsKey),
           let saved = try? JSONDecoder().decode([String: Int].self, from: data) {
            moodScores = saved
        } else {
            moodScores = [:]
        }

        // 评分体系升级：旧版“心情指数”与新版“感官负荷”方向相反，必须清空重算。
        if defaults.integer(forKey: "quietspace.scoringVersion") < 2 {
            moodScores = [:]
            defaults.set(2, forKey: "quietspace.scoringVersion")
            persistMoods()
        }

        // 演示账号预置一份已完成档案和今天的样例计划，方便直接看主功能。
        if account == "demo" && !hadProfile {
            profile.answers = [2, 1, 2, 1, 2, 2, 1, 1, 1, 1]
            profile.completed = true
            profile.solutionDate = Date()
        }
        if account == "demo" && plans.isEmpty {
            plans[DayKey.key(Date())] = DayPlan(events: [
                PlanEvent(
                    time: "08:30",
                    place: "图书馆",
                    title: "复习期中考试",
                    advice: "选择靠墙或角落的位置，随身带降噪耳机；每 40 分钟起身休息一次。"
                ),
                PlanEvent(
                    time: "12:10",
                    place: "食堂",
                    title: "午餐",
                    advice: "避开 12:00–12:30 的高峰，选靠窗座位，缩短排队时间。"
                ),
                PlanEvent(
                    time: "15:00",
                    place: "教学楼",
                    title: "小组讨论",
                    advice: "提前 5 分钟到场，先确认出口和安静角落；需要时可以短暂离场。"
                )
            ])
        }

        refreshAdvice()
        backfillMoodScores()
        persistProfile()
        persistPlans()
    }

    // MARK: - 档案

    func finishOnboarding(answers: [Int?], wearableLinked: Bool) {
        profile.answers = answers
        profile.completed = true
        profile.wearableLinked = wearableLinked
        profile.solutionDate = Date()
        persistProfile()
    }

    func setWearableLinked(_ linked: Bool) {
        profile.wearableLinked = linked
        persistProfile()
    }

    /// 清除上一次自测，让用户可以重新评估。
    func resetAssessment() {
        profile.answers = Array(repeating: nil, count: QuizData.questions.count)
        profile.completed = false
        profile.solutionDate = nil
        persistProfile()
    }

    // MARK: - 每日计划

    func plan(for date: Date) -> DayPlan {
        plans[DayKey.key(date)] ?? DayPlan()
    }

    func addEvent(on date: Date, time: String, place: String, title: String) {
        let key = DayKey.key(date)
        var plan = plans[key] ?? DayPlan()
        plan.events.append(
            PlanEvent(
                time: time,
                place: place,
                title: title,
                advice: AdviceEngine.advice(title: title, place: place, time: time)
            )
        )
        plans[key] = plan
        persistPlans()
    }

    func completeEvent(on date: Date, id: UUID, feeling: Feeling) {
        let key = DayKey.key(date)
        guard var plan = plans[key],
              let index = plan.events.firstIndex(where: { $0.id == id }) else { return }
        plan.events[index].isDone = true
        plan.events[index].feeling = feeling
        plans[key] = plan
        persistPlans()
    }

    func deleteEvent(on date: Date, id: UUID) {
        let key = DayKey.key(date)
        guard var plan = plans[key] else { return }
        plan.events.removeAll { $0.id == id }
        plans[key] = plan
        persistPlans()
    }

    func markReportGenerated(on date: Date, score: Int) {
        let key = DayKey.key(date)
        reportDays.insert(key)
        moodScores[key] = score
        persistReports()
        persistMoods()
    }

    func recentMoodDays(_ count: Int = 7, today: Date = Date()) -> [MoodDay] {
        (0..<count).reversed().map { offset in
            let date = Calendar.current.date(byAdding: .day, value: -offset, to: today) ?? today
            return MoodDay(date: date, score: moodScores[DayKey.key(date)])
        }
    }

    func hasReport(on date: Date) -> Bool {
        reportDays.contains(DayKey.key(date))
    }

    /// 每次启动按最新规则重算建议，老事件也会更新成更贴合场景的内容。
    private func refreshAdvice() {
        var changed = false
        for (key, plan) in plans {
            var updated = plan
            for index in updated.events.indices {
                let event = updated.events[index]
                let advice = AdviceEngine.advice(
                    title: event.title,
                    place: event.place,
                    time: event.time
                )
                if event.advice != advice {
                    updated.events[index].advice = advice
                    changed = true
                }
            }
            plans[key] = updated
        }
        if changed { persistPlans() }
    }

    // MARK: - 持久化

    private func persistProfile() {
        if let data = try? JSONEncoder().encode(profile) {
            defaults.set(data, forKey: profileKey)
        }
    }

    private func persistPlans() {
        if let data = try? JSONEncoder().encode(plans) {
            defaults.set(data, forKey: plansKey)
        }
    }

    private func backfillMoodScores() {
        var changed = false
        for key in reportDays where moodScores[key] == nil {
            guard let plan = plans[key], !plan.events.isEmpty,
                  plan.events.allSatisfy({ $0.isDone }) else { continue }
            moodScores[key] = MoodResult.calculate(events: plan.events).score
            changed = true
        }
        if changed { persistMoods() }
    }

    private func persistMoods() {
        if let data = try? JSONEncoder().encode(moodScores) {
            defaults.set(data, forKey: moodsKey)
        }
    }

    private func persistReports() {
        if let data = try? JSONEncoder().encode(reportDays) {
            defaults.set(data, forKey: reportsKey)
        }
    }
}
