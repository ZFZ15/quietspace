import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 桌面版默认以 1040 × 780 打开；用户仍可在运行中自由缩放。
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            guard let window = NSApp.windows.first(where: { $0.isVisible }) else { return }
            window.minSize = NSSize(width: 390, height: 700)
            let frame = NSRect(x: 0, y: 0, width: 1040, height: 780)
            window.setFrame(frame, display: true)
            window.center()
        }
    }
}
