import SwiftUI

@main
struct QuietSpaceApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    init() {
        if let index = CommandLine.arguments.firstIndex(of: "--lang"),
           index + 1 < CommandLine.arguments.count {
            UserDefaults.standard.set(CommandLine.arguments[index + 1], forKey: "quietspace.language")
        }
        CompanionAssets.preload()
        DebugCapture.scheduleIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .background(QS.bg)
                .tint(QS.accent)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentMinSize)
        .defaultSize(width: 1040, height: 780)
    }
}
