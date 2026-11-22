import SwiftUI
import AppKit

enum CompanionKind: String, CaseIterable, Identifiable {
    case cat
    case hamster
    case bunny
    case dog
    case hedgehog
    case duck

    var id: String { rawValue }

    var title: LocalizedStringKey {
        switch self {
        case .cat: return "小猫"
        case .hamster: return "仓鼠"
        case .bunny: return "小兔子"
        case .dog: return "小狗"
        case .hedgehog: return "小刺猬"
        case .duck: return "小鸭子"
        }
    }

    fileprivate var fallbackSymbol: String {
        switch self {
        case .cat: return "cat"
        case .hamster: return "pawprint"
        case .bunny: return "rabbit"
        case .dog: return "dog"
        case .hedgehog: return "leaf"
        case .duck: return "bird"
        }
    }
}

/// 读取用户提供的简笔画照片，去掉纸面背景后作为模板图使用。
enum CompanionAssets {
    private static var cache: [CompanionKind: NSImage] = [:]

    static func preload() {
        for kind in CompanionKind.allCases {
            _ = image(for: kind)
        }
    }

    static func image(for kind: CompanionKind) -> NSImage? {
        if let cached = cache[kind] { return cached }

        let name = "companion-\(kind.rawValue)"

        if let url = Bundle.main.url(forResource: name, withExtension: "png"),
           let image = NSImage(contentsOf: url) {
            cache[kind] = image
            return image
        }

        // 预览工具没有 App bundle，从源码目录读取同一份资源。
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let fallback = root.appendingPathComponent("Resources/\(name).png")
        if let image = NSImage(contentsOf: fallback) {
            cache[kind] = image
            return image
        }

        return nil
    }
}

struct CompanionView: View {
    let kind: CompanionKind
    var line: Color = QS.ink

    var body: some View {
        Group {
            if let image = CompanionAssets.image(for: kind) {
                Image(nsImage: image)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
                    .shadow(color: QS.ink.opacity(0.10), radius: 2, y: 1)
            } else {
                Image(systemName: kind.fallbackSymbol)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(line)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

/// 页面角落的小伙伴，轻轻起伏。
struct CompanionSprite: View {
    var size: CGFloat = 44
    var animated: Bool = true

    @AppStorage("quietspace.companion") private var companionRaw = CompanionKind.dog.rawValue
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var bouncing = false

    private var kind: CompanionKind {
        CompanionKind(rawValue: companionRaw) ?? .dog
    }

    var body: some View {
        CompanionView(kind: kind, line: QS.ink.opacity(0.78))
            .frame(width: size, height: size)
            .offset(y: bouncing ? -3 : 0)
            .rotationEffect(.degrees(bouncing ? 2 : 0), anchor: .bottom)
            .onAppear {
                guard animated, !reduceMotion else { return }
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    bouncing = true
                }
            }
            .accessibilityHidden(true)
    }
}

/// 烟花报告里跑出来跳几下的小伙伴。
struct CompanionCelebration: View {
    var size: CGFloat = 62
    var animated: Bool = true

    @AppStorage("quietspace.companion") private var companionRaw = CompanionKind.dog.rawValue
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var entered = false
    @State private var jumping = false

    private var kind: CompanionKind {
        CompanionKind(rawValue: companionRaw) ?? .dog
    }

    var body: some View {
        CompanionView(kind: kind, line: QS.ink.opacity(0.8))
            .frame(width: size, height: size)
            .offset(
                x: animated ? (entered ? 0 : -90) : 0,
                y: jumping ? -8 : 0
            )
            .rotationEffect(.degrees(jumping ? 3 : 0), anchor: .bottom)
            .onAppear {
                guard animated, !reduceMotion else {
                    entered = true
                    return
                }
                withAnimation(.spring(response: 0.6, dampingFraction: 0.72).delay(0.15)) {
                    entered = true
                }
                withAnimation(
                    .easeInOut(duration: 0.4)
                    .repeatCount(6, autoreverses: true)
                    .delay(0.5)
                ) {
                    jumping = true
                }
            }
            .accessibilityHidden(true)
    }
}
