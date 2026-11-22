import Foundation

/// 根据事件标题、地点和时间，匹配更贴近真实场景的初步建议。
enum AdviceEngine {
    private struct Scenario {
        let id: String
        let keywords: [String]
        let options: [String]
    }

    private static let scenarios: [Scenario] = [
        Scenario(
            id: "study",
            keywords: ["图书馆", "自习", "复习", "作业", "看书", "学习", "论文", "刷题", "背单词", "library", "study", "homework", "review", "reading"],
            options: [
                "选择靠墙或角落的位置，随身带降噪耳机；每 40 分钟起身休息一次。",
                "提前把手机调成静音，先列三件最重要的事；完成一件就去窗边站一会儿。",
                "如果人开始变多，换到靠窗的单人座；需要时用耳机播白噪音。"
            ]
        ),
        Scenario(
            id: "lecture",
            keywords: ["上课", "讲座", "听课", "培训", "课堂", "lecture", "class", "seminar"],
            options: [
                "坐在靠过道或后排，方便进出；提前 5 分钟到，先看一眼讲义结构。",
                "带一支笔和一张纸，把没听懂的地方记下来，课后只补最关键的两处。",
                "如果投影太亮或人声太杂，坐侧后方；中场休息时出去透口气。"
            ]
        ),
        Scenario(
            id: "exam",
            keywords: ["考试", "测验", "面试", "答辩", "exam", "test", "interview"],
            options: [
                "提前 15 分钟到，先在安静处做四次慢呼吸；把水和纸巾放在手边。",
                "进场前把手机静音，确认座位和出口；如果紧张，先写下一个开头。"
            ]
        ),
        Scenario(
            id: "meeting",
            keywords: ["会议", "讨论", "汇报", "演示", "开会", "组会", "meeting", "discussion", "presentation"],
            options: [
                "提前 5 分钟到场，先确认出口和安静角落；把议程写在纸上。",
                "选靠墙的位置，发言前先停顿两秒；需要时用一句“我整理一下”争取时间。",
                "如果人多，把自己的发言顺序提前；结束后可以直接离开，不必强迫社交。"
            ]
        ),
        Scenario(
            id: "nightmarket",
            keywords: ["夜市", "小吃街", "集市", "night market", "street food"],
            options: [
                "先走一圈看看人流，再决定买什么；拿好随身物品，尽量缩短停留。",
                "避开最挤的入口，从侧边摊位开始；买完就离开，不在人群中久站。"
            ]
        ),
        Scenario(
            id: "meal",
            keywords: ["食堂", "餐厅", "吃饭", "午餐", "晚餐", "早餐", "进食", "夜市", "餐", "eat", "lunch", "dinner", "cafeteria", "restaurant"],
            options: [
                "避开 12:00–12:30 和 18:00–18:30 的高峰，选靠窗座位，缩短排队时间。",
                "错峰 20 分钟再去，或者打包带走；人声太杂时换到角落。",
                "先找好座位再取餐，吃完就离开，不用在嘈杂处等同伴。"
            ]
        ),
        Scenario(
            id: "sport",
            keywords: ["体育", "操场", "体育场", "健身", "跑步", "游泳", "球", "gym", "run", "swim", "sport"],
            options: [
                "选人少的时段，提前热身；戴一只耳机听自己的节奏。",
                "先绕场走一圈确认出口和饮水点；强度以能正常说话为准。"
            ]
        ),
        Scenario(
            id: "sleep",
            keywords: ["睡觉", "午休", "休息", "宿舍", "睡前", "sleep", "nap", "rest", "dorm"],
            options: [
                "睡前 30 分钟调暗灯光，手机放远一点；用耳塞或白噪音。",
                "把明天第一件事写下来，避免躺下后反复想；室温调低一点。"
            ]
        ),
        Scenario(
            id: "commute",
            keywords: ["地铁", "公交", "火车", "机场", "车站", "通勤", "commute", "metro", "bus", "train", "airport"],
            options: [
                "避开最挤的班次，提前一班出门；站在车厢连接处或靠门位置。",
                "戴降噪耳机，背包放身前；换乘时留 10 分钟缓冲。",
                "如果人太多，等下一班；到站后先在人少处停一分钟再走。"
            ]
        ),
        Scenario(
            id: "shopping",
            keywords: ["超市", "商场", "购物", "逛街", "买东西", "shop", "mall", "grocery"],
            options: [
                "先列清单，按货架顺序走；避开周末下午的人流。",
                "戴耳机、走靠边通道；买完就离开，不临时加逛。"
            ]
        ),
        Scenario(
            id: "medical",
            keywords: ["医院", "看病", "体检", "牙医", "挂号", "hospital", "doctor", "clinic"],
            options: [
                "提前把证件和问题清单放在一个袋子里；选人少的时段挂号。",
                "候诊时坐靠墙位置，戴耳机；等待超过 30 分钟就去外面走一圈。"
            ]
        ),
        Scenario(
            id: "cinema",
            keywords: ["电影", "演出", "展览", "剧场", "音乐会", "cinema", "movie", "concert", "exhibition"],
            options: [
                "选靠过道的座位，提前 10 分钟进场；带耳塞以备音量过大。",
                "先看节目单，标记想看的段落；中场休息时出去透气。"
            ]
        ),
        Scenario(
            id: "social",
            keywords: ["聚会", "派对", "聚餐", "团建", "社交", "party", "gathering"],
            options: [
                "只待计划好的时长，提前想好一句离场的话；到场先找安静角落。",
                "和熟悉的人一起去，约定一个互相提醒的暗号；不强迫自己敬酒。"
            ]
        ),
        Scenario(
            id: "online",
            keywords: ["线上", "网课", "电话", "视频", "会议软件", "online", "zoom", "call", "video"],
            options: [
                "戴耳机，提前 5 分钟测试麦克风；把通知全部静音。",
                "关掉摄像头也没关系，先听；需要发言时再打开。"
            ]
        ),
        Scenario(
            id: "lab",
            keywords: ["实验", "机房", "画室", "工作室", "lab", "studio"],
            options: [
                "先确认通风和出口，把要用的东西放在手边；每 45 分钟出去透气。",
                "把步骤写在纸上，做完一步划掉一步，减少来回确认。"
            ]
        ),
        Scenario(
            id: "errands",
            keywords: ["银行", "政务", "办证", "排队", "快递", "bank", "office", "queue"],
            options: [
                "先在网上取号，避开午休前后；带好证件复印件。",
                "排队时站靠边，戴耳机；超过 40 分钟就改约下一个时段。"
            ]
        )
    ]

    private static let defaults = [
        "提前 5 分钟到场，先观察环境；把手机调成静音，给自己留一个可以退出的位置。",
        "先找到出口和安静角落；把任务拆成两步，做完一步就休息一下。",
        "如果现场比预期吵，缩短停留时间；离开后给自己 5 分钟恢复。"
    ]

    static func advice(title: String, place: String, time: String) -> String {
        let text = (title + " " + place).lowercased()

        for scenario in scenarios where scenario.keywords.contains(where: { text.contains($0.lowercased()) }) {
            let index = stableIndex(text + time, count: scenario.options.count)
            return scenario.options[index]
        }

        return defaults[stableIndex(text, count: defaults.count)]
    }

    private static func stableIndex(_ text: String, count: Int) -> Int {
        guard count > 0 else { return 0 }
        var hash: UInt64 = 5381
        for scalar in text.unicodeScalars {
            hash = hash &* 33 &+ UInt64(scalar.value)
        }
        return Int(hash % UInt64(count))
    }
}
