import SwiftUI
import AppKit

@main
struct SnapshotTool {
    @MainActor
    static func main() {
        UserDefaults.standard.set("zh", forKey: "quietspace.language")
        UserDefaults.standard.set("green", forKey: "quietspace.palette")
        CompanionAssets.preload()
        let out = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "screenshots"
        try? FileManager.default.createDirectory(atPath: out, withIntermediateDirectories: true)

        let store = AccountStore()
        let demo = SessionStore(account: "demo")

        let loginEmpty = LoginView(store: store, snapshot: true)
        let loginFilled = LoginView(store: store, snapshot: true, demoFill: true)
        let register = RegisterView(store: store, snapshot: true)
        let home = HomeView(screen: .constant(.home), justRegistered: false, snapshot: true).environmentObject(demo)
        let lockedModel = SessionStore(account: "preview-locked")
        let lockedHome = HomeView(screen: .constant(.home), justRegistered: true, snapshot: true).environmentObject(lockedModel)
        let feelingSheet = FeelingSheet(eventTitle: "小组讨论", onChoose: { _ in }, onCancel: {})
        let wearableSheet = WearablePermissionSheet { _ in }

        let toastHome = ZStack(alignment: .bottom) {
            HomeView(screen: .constant(.home), snapshot: true).environmentObject(demo)
            FeelingFeedbackToast(feeling: .overload)
                .padding(.horizontal, 24)
                .padding(.bottom, 76)
        }
        let galleryModel = SessionStore(account: "小满")
        if !galleryModel.profile.completed {
            galleryModel.finishOnboarding(answers: Array(repeating: 2, count: 10), wearableLinked: false)
        }
        if galleryModel.plan(for: Date()).events.isEmpty {
            galleryModel.addEvent(on: Date(), time: "08:30", place: "图书馆", title: "复习期中考试")
            galleryModel.addEvent(on: Date(), time: "12:10", place: "食堂", title: "午餐")
            galleryModel.addEvent(on: Date(), time: "15:00", place: "教学楼", title: "小组讨论")
        }
        let galleryHome = HomeView(screen: .constant(.home), snapshot: true)
            .environmentObject(galleryModel)

        let accountPage = AccountView(account: "demo", snapshot: true).environmentObject(demo)
        let settingsPage = SettingsView(snapshot: true).environmentObject(demo)
        let onboarding = OnboardingFlowView(onDone: {}, onClose: {}).environmentObject(demo)
        let quiz = OnboardingFlowView(onDone: {}, onClose: {}, previewQuiz: true).environmentObject(demo)

        let sampleReport = SolutionReport.build(answers: [2, 1, 2, 1, 2, 2, 1, 1, 1, 1])
        let report = SolutionReportView(report: sampleReport, snapshot: true, onContinue: {}, onOpenRule: {})
        let rule = RuleView(snapshot: true)

        let positiveEvents = [
            PlanEvent(time: "08:30", place: "图书馆", title: "复习", advice: "", isDone: true, feeling: .calm),
            PlanEvent(time: "12:10", place: "食堂", title: "午餐", advice: "", isDone: true, feeling: .calm),
            PlanEvent(time: "15:00", place: "教学楼", title: "讨论", advice: "", isDone: true, feeling: .tense)
        ]
        let negativeEvents = [
            PlanEvent(time: "08:30", place: "图书馆", title: "复习", advice: "", isDone: true, feeling: .tense),
            PlanEvent(time: "12:10", place: "食堂", title: "午餐", advice: "", isDone: true, feeling: .tense),
            PlanEvent(time: "15:00", place: "教学楼", title: "讨论", advice: "", isDone: true, feeling: .tense)
        ]
        let positive = DailyReportView(
            result: MoodResult(score: 26, zone: .stable, counts: [.stable: 2, .tense: 1], severeCount: 0),
            date: Date(),
            events: positiveEvents,
            snapshot: true,
            onClose: {}
        )
        let negative = DailyReportView(
            result: MoodResult(score: 51, zone: .tense, counts: [.stable: 1, .tense: 2], severeCount: 0),
            date: Date(),
            events: negativeEvents,
            snapshot: true,
            onClose: {}
        )
        let twoEventReport = DailyReportView(
            result: MoodResult(score: 78, zone: .overload, counts: [.overload: 2], severeCount: 0),
            date: Date(),
            events: [
                PlanEvent(time: "17:51", place: "教室", title: "晚课", advice: "", isDone: true, feeling: .overload),
                PlanEvent(time: "20:52", place: "宿舍", title: "小组讨论", advice: "", isDone: true, feeling: .overload)
            ],
            snapshot: true,
            onClose: {}
        )

        render(loginEmpty.frame(width: 390, height: 844), to: "\(out)/01-login-empty.png")
        render(loginFilled.frame(width: 390, height: 844), to: "\(out)/02-login-filled.png")
        render(register.frame(width: 390, height: 844), to: "\(out)/03-register.png")
        render(home.frame(width: 390, height: 844), to: "\(out)/04-home.png")
        render(toastHome.frame(width: 390, height: 844), to: "\(out)/42-feeling-toast.png")
        render(feelingSheet.frame(width: 390, height: 430), to: "\(out)/58-feeling-zh.png")
        render(wearableSheet.frame(width: 390, height: 640), to: "\(out)/59-wearable-zh.png")
        render(accountPage.frame(width: 390, height: 844), to: "\(out)/08-account.png")
        render(settingsPage.frame(width: 390, height: 900), to: "\(out)/09-settings.png")
        render(galleryHome.frame(width: 390, height: 844), to: "\(out)/52-home-gallery.png")
        render(onboarding.frame(width: 390, height: 844), to: "\(out)/10-onboarding-intro.png")
        render(quiz.frame(width: 390, height: 844), to: "\(out)/15-quiz.png")
        render(report.frame(width: 390, height: 1000), to: "\(out)/11-solution-report.png")
        render(positive.frame(width: 390, height: 1000), to: "\(out)/12-daily-report-positive.png")
        render(negative.frame(width: 390, height: 1000), to: "\(out)/13-daily-report-support.png")
        render(twoEventReport.frame(width: 390, height: 1000), to: "\(out)/44-daily-report-two-events.png")
        render(rule.frame(width: 390, height: 844), to: "\(out)/14-rule.png")
        render(lockedHome.frame(width: 390, height: 844), to: "\(out)/16-home-locked.png")

        let deleteModel = SessionStore(account: "preview-delete")
        let today = Date()
        if deleteModel.plan(for: today).events.isEmpty {
            deleteModel.addEvent(on: today, time: "09:00", place: "图书馆", title: "复习")
            deleteModel.addEvent(on: today, time: "14:00", place: "教室", title: "小组讨论")
            if let first = deleteModel.plan(for: today).events.first {
                deleteModel.completeEvent(on: today, id: first.id, feeling: .calm)
            }
        }
        deleteModel.markReportGenerated(on: today, score: 80)
        let deletePreview = DailyPlanView(snapshot: true, previewDelete: true).environmentObject(deleteModel)
        render(
            deletePreview
                .padding(20)
                .frame(width: 390, height: 640, alignment: .top)
                .background(QS.bg),
            to: "\(out)/17-delete.png"
        )

        let desktop = HStack(spacing: 0) {
            DesktopSidebar(screen: .constant(.home), onLogout: {}, onStartOnboarding: {})
                .environmentObject(demo)
            HomeView(screen: .constant(.home), snapshot: true, showsChrome: false)
                .environmentObject(demo)
        }
        .frame(width: 1040, height: 780)
        .background(QS.bg)
        render(desktop, to: "\(out)/18-desktop.png", scale: 1.4)

        let variety = SessionStore(account: "preview-variety")
        if !variety.profile.completed {
            variety.finishOnboarding(answers: Array(repeating: 2, count: 10), wearableLinked: false)
        }
        let varietyDate = Date()
        if variety.plan(for: varietyDate).events.isEmpty {
            variety.addEvent(on: varietyDate, time: "17:03", place: "教室", title: "复习期中考试")
            variety.addEvent(on: varietyDate, time: "18:04", place: "体育场", title: "体育课")
            variety.addEvent(on: varietyDate, time: "17:04", place: "商学院", title: "听讲座")
            variety.addEvent(on: varietyDate, time: "18:04", place: "餐厅", title: "吃晚饭")
            variety.addEvent(on: varietyDate, time: "23:05", place: "宿舍", title: "睡觉")
            variety.addEvent(on: varietyDate, time: "17:06", place: "苏州中心", title: "开一个国际会议")
            variety.addEvent(on: varietyDate, time: "17:06", place: "夜市", title: "进食")
        }
        let varietyHome = HomeView(screen: .constant(.home), snapshot: true)
            .environmentObject(variety)
        render(varietyHome.frame(width: 390, height: 1100), to: "\(out)/36-advice-variety.png")

        let trend = SessionStore(account: "preview-trend-gap")
        if !trend.profile.completed {
            trend.finishOnboarding(answers: Array(repeating: 2, count: 10), wearableLinked: false)
        }
        let trendScores: [Int?] = [72, 58, 81, nil, 74, 68, 76]
        for (offset, score) in trendScores.enumerated() {
            if let score, let day = Calendar.current.date(byAdding: .day, value: offset - 6, to: Date()) {
                trend.markReportGenerated(on: day, score: score)
            }
        }
        let trendHome = HomeView(screen: .constant(.home), snapshot: true)
            .environmentObject(trend)
        render(trendHome.frame(width: 390, height: 1100), to: "\(out)/41-mood-trend.png")

        for palette in [QSPalette.red, .pink, .blue, .yellow] {
            UserDefaults.standard.set(palette.rawValue, forKey: "quietspace.palette")
            let themed = HomeView(screen: .constant(.home), snapshot: true)
                .environmentObject(demo)
            render(themed.frame(width: 390, height: 844), to: "\(out)/47-home-\(palette.rawValue).png")
        }
        UserDefaults.standard.set("green", forKey: "quietspace.palette")
        CompanionAssets.preload()

        let overview = HStack(alignment: .top, spacing: 26) {
            loginFilled.frame(width: 390, height: 844)
            register.frame(width: 390, height: 844)
            home.frame(width: 390, height: 844)
        }
        .padding(36)
        .background(QS.bg)

        render(overview, to: "\(out)/00-overview.png", scale: 1.4)

        // English previews
        UserDefaults.standard.set("en", forKey: "quietspace.language")
        let en = Locale(identifier: "en")
        let loginEN = LoginView(store: store, snapshot: true)
            .environment(\.locale, en)
        render(loginEN.frame(width: 390, height: 844), to: "\(out)/45-login-en.png", locale: "en")

        let trendEN = HomeView(screen: .constant(.home), snapshot: true)
            .environmentObject(trend)
            .environment(\.locale, en)
        render(trendEN.frame(width: 390, height: 1100), to: "\(out)/46-mood-trend-en.png", locale: "en")

        let homeEN = HomeView(screen: .constant(.home), snapshot: true)
            .environmentObject(demo)
            .environment(\.locale, en)
        render(homeEN.frame(width: 390, height: 844), to: "\(out)/19-home-en.png", locale: "en")

        let reportEN = SolutionReportView(report: sampleReport, snapshot: true, onContinue: {}, onOpenRule: {})
            .environment(\.locale, en)
        render(reportEN.frame(width: 390, height: 1000), to: "\(out)/20-report-en.png", locale: "en")

        let accountEN = AccountView(account: "demo", snapshot: true)
            .environmentObject(demo)
            .environment(\.locale, en)
        render(accountEN.frame(width: 390, height: 844), to: "\(out)/24-account-en.png", locale: "en")

        let dailyEN = DailyReportView(
            result: MoodResult(score: 26, zone: .stable, counts: [.stable: 2, .tense: 1], severeCount: 0),
            date: Date(),
            events: positiveEvents,
            snapshot: true,
            onClose: {}
        )
        .environment(\.locale, en)
        render(dailyEN.frame(width: 390, height: 1000), to: "\(out)/25-daily-report-en.png", locale: "en")

        let introEN = OnboardingFlowView(onDone: {}, onClose: {})
            .environmentObject(demo)
            .environment(\.locale, en)
        render(introEN.frame(width: 390, height: 844), to: "\(out)/26-onboarding-en.png", locale: "en")

        let ruleEN = RuleView(snapshot: true)
            .environment(\.locale, en)
        render(ruleEN.frame(width: 390, height: 1100), to: "\(out)/27-rule-en.png", locale: "en")

        let wearableEN = WearablePermissionSheet { _ in }
            .environment(\.locale, en)
        render(wearableEN.frame(width: 390, height: 640), to: "\(out)/28-wearable-en.png", locale: "en")

        let settingsEN = SettingsView(snapshot: true)
            .environmentObject(demo)
            .environment(\.locale, en)
        render(settingsEN.frame(width: 390, height: 900), to: "\(out)/21-settings-en.png", locale: "en")

        let quizEN = OnboardingFlowView(onDone: {}, onClose: {}, previewQuiz: true)
            .environmentObject(demo)
            .environment(\.locale, en)
        render(quizEN.frame(width: 390, height: 844), to: "\(out)/22-quiz-en.png", locale: "en")

        let addEN = AddEventSheet(onSave: { _, _, _ in }, onCancel: {})
            .environment(\.locale, en)
        render(addEN.frame(width: 390, height: 620), to: "\(out)/29-add-event-en.png", locale: "en")

        let feelingEN = FeelingSheet(eventTitle: "Review for midterm", onChoose: { _ in }, onCancel: {})
            .environment(\.locale, en)
        render(feelingEN.frame(width: 390, height: 430), to: "\(out)/30-feeling-en.png", locale: "en")

        let registerEN = RegisterView(store: store, snapshot: true)
            .environment(\.locale, en)
        render(registerEN.frame(width: 390, height: 844), to: "\(out)/31-register-en.png", locale: "en")

        let supportEN = DailyReportView(
            result: MoodResult(score: 85, zone: .overload, counts: [.overload: 1], severeCount: 1),
            date: Date(),
            events: [PlanEvent(time: "18:30", place: "餐厅", title: "晚餐", advice: "", isDone: true, feeling: .overload)],
            snapshot: true,
            onClose: {}
        )
        .environment(\.locale, en)
        render(supportEN.frame(width: 390, height: 1000), to: "\(out)/33-support-en.png", locale: "en")

        let quoteEN = QuoteDetailView(quote: "今天已经尽力了，休息不是退步。")
            .environment(\.locale, en)
        render(quoteEN, to: "\(out)/34-quote-en.png", locale: "en")

        let desktopEN = HStack(spacing: 0) {
            DesktopSidebar(screen: .constant(.home), onLogout: {}, onStartOnboarding: {})
                .environmentObject(demo)
            HomeView(screen: .constant(.home), snapshot: true, showsChrome: false)
                .environmentObject(demo)
        }
        .frame(width: 1040, height: 780)
        .background(QS.bg)
        .environment(\.locale, en)
        render(desktopEN, to: "\(out)/23-desktop-en.png", scale: 1.4, locale: "en")

        UserDefaults.standard.set("zh", forKey: "quietspace.language")
        UserDefaults.standard.set("green", forKey: "quietspace.palette")
        CompanionAssets.preload()
    }

    @MainActor
    static func render<V: View>(_ view: V, to path: String, scale: CGFloat = 2, locale: String = "zh-Hans") {
        let localized = view.environment(\.locale, Locale(identifier: locale))
        let renderer = ImageRenderer(content: localized)
        renderer.scale = scale
        guard
            let image = renderer.nsImage,
            let tiff = image.tiffRepresentation,
            let rep = NSBitmapImageRep(data: tiff),
            let png = rep.representation(using: .png, properties: [:])
        else {
            print("render failed: \(path)")
            return
        }
        do {
            try png.write(to: URL(fileURLWithPath: path))
            print("wrote \(path)")
        } catch {
            print("write failed: \(path) — \(error.localizedDescription)")
        }
    }
}
