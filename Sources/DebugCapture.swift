import AppKit
import SwiftUI

/// 仅用于开发验证：把运行中的真实窗口截成 PNG。
/// 屏幕录制权限被系统限制时，仍可在进程内取到窗口渲染结果。
enum DebugCapture {
    static var requestedPath: String? {
        guard
            let index = CommandLine.arguments.firstIndex(of: "--capture"),
            index + 1 < CommandLine.arguments.count
        else { return nil }
        return CommandLine.arguments[index + 1]
    }

    static func scheduleIfNeeded() {
        guard let path = requestedPath else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) {
            NSApp.activate(ignoringOtherApps: true)
            attempt(path: path, deadline: Date().addingTimeInterval(12))
        }
    }

    private static func attempt(path: String, deadline: Date) {
        if let hidden = NSApp.windows.first(where: { !$0.isVisible }) {
            hidden.makeKeyAndOrderFront(nil)
        }
        if let sheet = NSApp.windows.first(where: { $0.isSheet || $0.sheetParent != nil }),
           let view = sheet.contentView {
            capture(view: view, window: sheet, to: path)
            fflush(stdout)
            exit(0)
        }

        if let window = NSApp.keyWindow ?? NSApp.windows.first(where: { $0.isVisible }),
           let view = window.contentView {
            capture(view: view, window: window, to: path)
            fflush(stdout)
            exit(0)
        }

        if Date() > deadline {
            print("capture: no visible window. total=\(NSApp.windows.count)")
            for window in NSApp.windows {
                print("  window '\(window.title)' visible=\(window.isVisible) frame=\(window.frame)")
            }
            if let window = NSApp.windows.first, let view = window.contentView {
                capture(view: view, window: window, to: path)
            }
            fflush(stdout)
            exit(1)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            attempt(path: path, deadline: deadline)
        }
    }

    private static func capture(view: NSView, window: NSWindow, to path: String) {
        let bounds = view.bounds
        guard let rep = view.bitmapImageRepForCachingDisplay(in: bounds) else {
            print("capture: cannot allocate bitmap")
            return
        }
        view.cacheDisplay(in: bounds, to: rep)
        if let data = rep.representation(using: .png, properties: [:]) {
            try? data.write(to: URL(fileURLWithPath: path))
            print("capture: \(rep.pixelsWide)x\(rep.pixelsHigh) -> \(path)")
        }
    }
}
