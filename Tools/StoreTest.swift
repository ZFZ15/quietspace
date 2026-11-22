import Foundation

@main
struct StoreTest {
    static func main() {
        var failures = 0

        func check(_ condition: Bool, _ name: String) {
            print(condition ? "PASS  \(name)" : "FAIL  \(name)")
            if !condition { failures += 1 }
        }

        // 账号
        let store = AccountStore()
        check(store.login(account: "demo", password: "123456"), "演示账号可以登录")
        check(!store.login(account: "demo", password: "wrong"), "错误密码被拒绝")
        check(!store.login(account: "nobody", password: "123456"), "不存在的账号被拒绝")

        let name = "test\(Int(Date().timeIntervalSince1970))"
        check(store.register(account: name, password: "abcdef", confirm: "abcdef") == nil, "新账号注册成功")
        check(store.login(account: name, password: "abcdef"), "注册后可以登录")
        check(store.register(account: name, password: "abcdef", confirm: "abcdef") != nil, "重复账号被拒绝")
        check(store.register(account: "x", password: "abcdef", confirm: "abcdef") != nil, "账号过短被拒绝")
        check(store.register(account: "abc", password: "123", confirm: "123") != nil, "密码过短被拒绝")
        check(store.register(account: "abcd", password: "123456", confirm: "1234567") != nil, "两次密码不一致被拒绝")

        // 问卷计分
        check(QuizScoring.total(Array(repeating: 0, count: 10)) == 0, "十题全 0 得 0 分")
        check(QuizScoring.total(Array(repeating: 4, count: 10)) == 40, "十题全 4 得 40 分")
        check(QuizScoring.total([0, nil, 0, 0, 0, 0, 0, 0, 0, 0]) == nil, "有留空时暂无总分")
        check(QuizScoring.band(for: 0).title.contains("未报告"), "0 分区间匹配")
        check(QuizScoring.band(for: 10).title.contains("部分体验"), "1–13 分区间匹配")
        check(QuizScoring.band(for: 20).title.contains("多项体验"), "14–26 分区间匹配")
        check(QuizScoring.band(for: 35).title.contains("反复"), "27–40 分区间匹配")

        let fullReport = SolutionReport.build(answers: Array(repeating: 4, count: 10))
        check(fullReport.total == 40, "报告总分为 40")
        check(fullReport.topItems.count == 3, "高信号场景最多三条")

        // 账号档案与每日计划
        let account = "session-\(UUID().uuidString)"
        let model = SessionStore(account: account)
        let date = Date()

        check(!model.profile.completed, "新账号默认未完成自测")
        model.finishOnboarding(answers: Array(repeating: 2, count: 10), wearableLinked: true)
        check(model.profile.completed, "完成自测后标记为已完成")
        check(model.profile.wearableLinked, "穿戴设备状态可以保存")

        model.addEvent(on: date, time: "09:00", place: "图书馆", title: "复习")
        model.addEvent(on: date, time: "12:00", place: "食堂", title: "午餐")
        let events = model.plan(for: date).events
        check(events.count == 2, "可以添加每日事件")
        check(!events[0].advice.isEmpty, "事件会自动生成建议")

        model.completeEvent(on: date, id: events[0].id, feeling: .calm)
        model.completeEvent(on: date, id: events[1].id, feeling: .overload)
        let updated = model.plan(for: date).events
        check(updated[0].isDone && updated[0].feeling == .calm, "完成事件并记录平稳")
        check(updated[1].feeling == .overload, "完成事件并记录过载")

        check(SensoryZone.zone(for: 39) == .stable, "39 分属于平稳区")
        check(SensoryZone.zone(for: 40) == .tense, "40 分进入紧张区")
        check(SensoryZone.zone(for: 69) == .tense, "69 分仍在紧张区")
        check(SensoryZone.zone(for: 70) == .overload, "70 分进入过载区")

        let calmLibrary = PlanEvent(time: "09:00", place: "图书馆", title: "复习", advice: "", isDone: true, feeling: .calm)
        let overloadLibrary = PlanEvent(time: "10:00", place: "图书馆", title: "复习", advice: "", isDone: true, feeling: .overload)
        let calmScore = SensoryScoring.eventScore(for: calmLibrary) ?? 0
        let overloadScore = SensoryScoring.eventScore(for: overloadLibrary) ?? 0
        check(calmScore < 40, "安静场景 + 平稳感受落在平稳区")
        check(overloadScore >= 70, "安静场景 + 过载感受仍进入过载区")

        let result = MoodResult.calculate(events: updated)
        check(result.severeCount == 1, "食堂过载事件触发重度过载计数")
        check(result.zone == .overload, "出现重度过载时，当天整体进入过载区")
        check(result.counts[.stable] == 1 && result.counts[.overload] == 1, "区间计数按事件负荷统计")

        let allOverload = [
            PlanEvent(time: "09:00", place: "A", title: "x", advice: "", isDone: true, feeling: .overload),
            PlanEvent(time: "10:00", place: "B", title: "y", advice: "", isDone: true, feeling: .overload),
            PlanEvent(time: "11:00", place: "C", title: "z", advice: "", isDone: true, feeling: .overload)
        ]
        check(MoodResult.calculate(events: allOverload).zone == .overload, "三次过载全部落在过载区")

        let reloaded = SessionStore(account: account)
        check(reloaded.profile.completed, "重启后自测状态仍然存在")
        check(reloaded.plan(for: date).events.count == 2, "重启后每日计划仍然存在")
        check(reloaded.plan(for: date).events[1].feeling == .overload, "重启后感受记录仍然存在")

        // 出报告后删除事件
        model.markReportGenerated(on: date, score: 72)
        check(model.hasReport(on: date), "生成报告后标记当天已出报告")

        let deletedID = model.plan(for: date).events[0].id
        model.deleteEvent(on: date, id: deletedID)
        check(model.plan(for: date).events.count == 1, "删除事件后数量减少")
        check(!model.plan(for: date).events.contains { $0.id == deletedID }, "删除后事件不存在")

        let afterDelete = SessionStore(account: account)
        check(!afterDelete.plan(for: date).events.contains { $0.id == deletedID }, "删除后重启仍然不存在")
        check(afterDelete.hasReport(on: date), "报告标记持久化")
        check(afterDelete.recentMoodDays().last?.score == 72, "报告分数会进入近 7 天趋势")
        check(afterDelete.recentMoodDays().count == 7, "趋势固定返回七天")

        // 重新评估：清除上次自测
        afterDelete.resetAssessment()
        check(!afterDelete.profile.completed, "清除自测后变为未完成")
        check(afterDelete.profile.answers.allSatisfy { $0 == nil }, "清除自测后答案清空")
        check(afterDelete.profile.solutionDate == nil, "清除自测后方案日期清空")

        let afterReset = SessionStore(account: account)
        check(!afterReset.profile.completed, "清除自测后重启仍然未完成")
        check(afterReset.plan(for: date).events.count == 1, "重新评估不会清空每日计划")

        check(QSPalette.allCases.count == 5, "提供 5 套界面配色")
        check(QSPalette(rawValue: "blue") != nil, "配色可以从存储值恢复")
        check(CompanionKind.allCases.count == 6, "提供六种贴纸小伙伴")
        check(CompanionKind(rawValue: "cat") != nil, "小伙伴选择可以恢复")

        // 场景建议
        let study = AdviceEngine.advice(title: "复习期中考试", place: "教室", time: "17:03")
        let sport = AdviceEngine.advice(title: "体育课", place: "体育场", time: "18:04")
        let lecture = AdviceEngine.advice(title: "听讲座", place: "商学院", time: "17:04")
        let meal = AdviceEngine.advice(title: "吃晚饭", place: "餐厅", time: "18:04")
        let sleep = AdviceEngine.advice(title: "睡觉", place: "宿舍", time: "23:05")
        check(study != sport, "学习与运动建议不同")
        check(lecture != sport, "讲座与运动建议不同")
        check(meal.contains("高峰") || meal.contains("错峰") || meal.contains("座位"), "用餐场景给出用餐建议")
        check(sleep.contains("睡前") || sleep.contains("明天") || sleep.contains("耳塞"), "睡眠场景给出睡前建议")

        exit(failures == 0 ? 0 : 1)
    }
}
