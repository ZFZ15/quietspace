import SwiftUI

// MARK: - 问卷

struct QuizQuestion: Identifiable {
    let id: Int
    let section: String
    let text: String
    let short: String
}

enum QuizData {
    static let options = ["0 天", "1–2 天", "3–5 天", "6–9 天", "10–14 天"]

    static let questions: [QuizQuestion] = [
        .init(id: 1, section: "对环境刺激的反应", text: "环境中的声音、光线、气味、触碰或拥挤让我觉得难以承受。", short: "环境刺激难以承受"),
        .init(id: 2, section: "对环境刺激的反应", text: "几种环境刺激同时出现时，我觉得很难应付。", short: "多种刺激同时出现"),
        .init(id: 3, section: "对环境刺激的反应", text: "周围的刺激让我明显难以放松。", short: "难以放松"),
        .init(id: 4, section: "专注和沟通", text: "周围的刺激让我很难集中注意力。", short: "难以集中注意力"),
        .init(id: 5, section: "专注和沟通", text: "周围的刺激让我很难跟上交谈。", short: "难以跟上交谈"),
        .init(id: 6, section: "活动和安排", text: "我因为周围的刺激，不得不暂停正在做的事。", short: "不得不暂停"),
        .init(id: 7, section: "活动和安排", text: "我因为周围的刺激，没能完成原本要做的事。", short: "没能完成计划"),
        .init(id: 8, section: "活动和安排", text: "为了避开让我难受的刺激，我不得不改动原先的安排。", short: "不得不改安排"),
        .init(id: 9, section: "应对和恢复", text: "为了继续活动，我需要花明显的额外精力减弱周围的刺激。", short: "需要额外精力"),
        .init(id: 10, section: "应对和恢复", text: "刺激减弱或离开现场后，我仍因不适而难以继续日常活动。", short: "离开后仍难恢复")
    ]
}

// MARK: - 计分与解决方案

struct QuizSuggestion: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let body: String
}

struct QuizBand {
    let title: String
    let summary: String
    let suggestions: [QuizSuggestion]
}

enum QuizScoring {
    static func total(_ answers: [Int?]) -> Int? {
        if answers.contains(where: { $0 == nil }) { return nil }
        return answers.compactMap { $0 }.reduce(0, +)
    }

    static func band(for score: Int) -> QuizBand {
        switch score {
        case 0:
            return QuizBand(
                title: "本期未报告所列体验",
                summary: "过去 14 天，这 10 项经历在你的回忆里都很少出现。可以记下哪些环境让你觉得自在，之后安排同类活动时继续沿用。",
                suggestions: [
                    .init(icon: "leaf", title: "保持现在的节奏", body: "你目前的环境和作息大致合适，不需要额外调整。"),
                    .init(icon: "bookmark", title: "记录有效条件", body: "记下让你舒服的座位、时段和活动方式，下次直接复用。"),
                    .init(icon: "clock", title: "保留固定作息", body: "稳定的睡眠和用餐时间，能帮你在环境变化时更从容。")
                ]
            )
        case 1...13:
            return QuizBand(
                title: "有部分体验值得回顾",
                summary: "你回忆到至少一项与环境刺激有关的体验。有人只在特定场所觉得难受，也有人不太介意刺激本身，却要花额外精力才能继续。",
                suggestions: [
                    .init(icon: "magnifyingglass", title: "找出最难受的一题", body: "回想当时在做什么、周围有什么声音或光线，先找到一个具体场景。"),
                    .init(icon: "slider.horizontal.3", title: "微调一个场景", body: "只改一个变量，比如换到靠墙的位置，或把活动挪到人少的时段。"),
                    .init(icon: "moon", title: "留出恢复时间", body: "在一件消耗较大的事之后，给自己 10–15 分钟安静时间。")
                ]
            )
        case 14...26:
            return QuizBand(
                title: "多项体验或日常影响有记录",
                summary: "这两周里，你报告了多项体验。可以分别回看：哪些刺激让你不舒服、哪些场景影响了专注、哪些活动需要暂停或改动。",
                suggestions: [
                    .init(icon: "target", title: "一次只改一个场景", body: "选一个最想改善的日常场景，先调整它，不要同时改变所有习惯。"),
                    .init(icon: "headphones", title: "准备降噪工具", body: "把耳机、帽子或墨镜放在随手可取的位置，需要时立刻用上。"),
                    .init(icon: "hand.raised", title: "建立「退出信号」", body: "和同伴约好一个手势或短句，需要离场时可以不用解释太多。")
                ]
            )
        default:
            return QuizBand(
                title: "多项体验反复出现",
                summary: "按这组回答，至少六项体验在过去 14 天里各出现过 3 天或更多。先看看哪些经历最影响你想做的事，再决定优先调整哪一块。",
                suggestions: [
                    .init(icon: "shield", title: "优先减少高刺激时段", body: "把必须完成的事尽量安排在刺激较少的时间和人流较少的路线。"),
                    .init(icon: "calendar", title: "把恢复写进日程", body: "每天预留一段不安排任务的安静时间，像约会一样固定下来。"),
                    .init(icon: "cross.case", title: "考虑寻求专业支持", body: "如果这些体验持续影响上课、出行或休息，可以带着记录咨询校医院或心理中心。")
                ]
            )
        }
    }

    static func missingBand() -> QuizBand {
        QuizBand(
            title: "已记录部分体验",
            summary: "还有题目没有作答，这次先用已记录的内容给你一份初步方向。等能回想起更多信息时，可以重新完成问卷。",
            suggestions: [
                .init(icon: "pencil.line", title: "先从记得清楚的场景开始", body: "不需要一次想全，先记录最近一次明显不舒服的经历。"),
                .init(icon: "clock.arrow.circlepath", title: "观察时间和地点", body: "留意刺激出现的时间、当时在做的事，以及之后多久恢复。"),
                .init(icon: "arrow.clockwise", title: "之后补完问卷", body: "等信息更完整时重新作答，结果会更贴近你的日常。")
            ]
        )
    }
}

struct SolutionReport {
    let band: QuizBand
    let topItems: [(question: QuizQuestion, value: Int)]
    let answered: Int
    let total: Int?
    let date: Date

    static func build(answers: [Int?]) -> SolutionReport {
        let total = QuizScoring.total(answers)
        let band = total.map { QuizScoring.band(for: $0) } ?? QuizScoring.missingBand()

        let ranked = answers.enumerated()
            .compactMap { index, value -> (QuizQuestion, Int)? in
                guard let value, value > 0 else { return nil }
                return (QuizData.questions[index], value)
            }
            .sorted {
                if $0.1 != $1.1 { return $0.1 > $1.1 }
                return $0.0.id < $1.0.id
            }
            .prefix(3)

        return SolutionReport(
            band: band,
            topItems: ranked.map { ($0.0, $0.1) },
            answered: answers.compactMap { $0 }.count,
            total: total,
            date: Date()
        )
    }
}

// MARK: - 每日计划

enum Feeling: String, Codable, CaseIterable, Identifiable {
    case calm
    case tense
    case overload

    var id: String { rawValue }

    var title: String {
        switch self {
        case .calm: return "平稳"
        case .tense: return "紧绷"
        case .overload: return "过载"
        }
    }

    var color: Color {
        switch self {
        case .calm: return Color(hex: 0x5E8C6A)
        case .tense: return Color(hex: 0xC9A227)
        case .overload: return Color(hex: 0xB25C4C)
        }
    }

}

/// 感官负荷三区间：分数越高，负荷越重。
enum SensoryZone: String, CaseIterable, Identifiable, Codable {
    case stable
    case tense
    case overload

    var id: String { rawValue }

    var title: LocalizedStringKey {
        switch self {
        case .stable: return "平稳"
        case .tense: return "紧张"
        case .overload: return "过载"
        }
    }

    var color: Color {
        switch self {
        case .stable: return Color(hex: 0x5E8C6A)
        case .tense: return Color(hex: 0xC9A227)
        case .overload: return Color(hex: 0xB25C4C)
        }
    }

    var seal: String {
        switch self {
        case .stable: return "安"
        case .tense: return "缓"
        case .overload: return "退"
        }
    }

    var bookmarkTitle: String {
        switch self {
        case .stable: return "人间安康"
        case .tense: return "缓步徐行"
        case .overload: return "暂避锋芒"
        }
    }

    var bookmarkLines: [String] {
        switch self {
        case .stable: return ["心平气和", "诸事可亲"]
        case .tense: return ["风起时", "先缓一口气"]
        case .overload: return ["今日先退", "来日方长"]
        }
    }

    static func zone(for score: Int) -> SensoryZone {
        if score <= 39 { return .stable }
        if score <= 69 { return .tense }
        return .overload
    }
}

enum SensoryScoring {
    /// 事件本身的感官刺激基础分（0–100）。
    static func baseLoad(for event: PlanEvent) -> Double {
        let text = (event.title + " " + event.place).lowercased()

        let intense = ["夜市", "体育", "演唱会", "派对", "聚会", "酒吧", "医院", "机场", "night market", "party", "concert", "gym", "hospital", "airport"]
        let busy = ["食堂", "餐厅", "会议", "讲座", "商场", "超市", "地铁", "公交", "车站", "cafeteria", "meeting", "lecture", "mall", "station", "subway", "bus", "restaurant"]
        let mild = ["教室", "上课", "办公室", "咖啡", "书店", "实验室", "class", "office", "cafe", "lab"]
        let quiet = ["图书馆", "宿舍", "自习", "看书", "家", "公园", "library", "dorm", "home", "study", "park"]

        if intense.contains(where: { text.contains($0) }) { return 80 }
        if busy.contains(where: { text.contains($0) }) { return 65 }
        if mild.contains(where: { text.contains($0) }) { return 50 }
        if quiet.contains(where: { text.contains($0) }) { return 38 }
        return 55
    }

    /// 调节系数：平稳时抑制负荷，过载时放大负荷。
    static func coefficient(for feeling: Feeling) -> Double {
        switch feeling {
        case .calm: return 0.55
        case .tense: return 1.0
        case .overload: return 1.9
        }
    }

    /// 单事件得分 = 基础刺激分 × 调节系数，最高 100。
    static func eventScore(for event: PlanEvent) -> Int? {
        guard let feeling = event.feeling else { return nil }
        let raw = baseLoad(for: event) * coefficient(for: feeling)
        return min(100, Int(raw.rounded()))
    }
}

struct PlanEvent: Codable, Identifiable, Equatable {
    var id = UUID()
    var time: String
    var place: String
    var title: String
    var advice: String
    var isDone = false
    var feeling: Feeling?
}

struct DayPlan: Codable {
    var events: [PlanEvent] = []
}

enum DayKey {
    static var isEnglish: Bool {
        UserDefaults.standard.string(forKey: "quietspace.language") == "en"
    }

    static func key(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    static func monthDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: isEnglish ? "en_US" : "zh_CN")
        formatter.dateFormat = isEnglish ? "MMM d" : "M月d日"
        return formatter.string(from: date)
    }

    static func display(_ date: Date) -> String {
        let base = monthDay(date)
        if isEnglish {
            if Calendar.current.isDateInToday(date) {
                return "Today (\(base))"
            }
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US")
            formatter.dateFormat = "EEEE"
            return "\(base) · \(formatter.string(from: date))"
        }
        if Calendar.current.isDateInToday(date) {
            return "今天（\(base)）"
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "EEEE"
        return "\(base) \(formatter.string(from: date))"
    }
}

struct MoodDay: Identifiable {
    let date: Date
    let score: Int?
    var id: Date { date }
}

struct MoodResult {
    let score: Int
    let zone: SensoryZone
    let counts: [SensoryZone: Int]
    let severeCount: Int

    static func calculate(events: [PlanEvent]) -> MoodResult {
        let scores = events.compactMap { SensoryScoring.eventScore(for: $0) }
        let average = scores.isEmpty ? 0 : Int((Double(scores.reduce(0, +)) / Double(scores.count)).rounded())
        let severe = scores.filter { $0 >= 85 }.count
        // 只要出现重度过载，就把当天整体拉到过载区，避免平均值掩盖风险。
        let daily = severe > 0 ? max(average, 85) : average

        var counts: [SensoryZone: Int] = [:]
        for score in scores {
            counts[SensoryZone.zone(for: score), default: 0] += 1
        }

        return MoodResult(
            score: min(100, daily),
            zone: SensoryZone.zone(for: daily),
            counts: counts,
            severeCount: severe
        )
    }
}

// MARK: - 设置里的穿戴设备状态

enum WearableState {
    case notLinked
    case linked
}
