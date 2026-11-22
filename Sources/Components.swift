import SwiftUI

/// 静界的标志：一片叶子，低饱和，无动效。
struct QSLogo: View {
    var size: CGFloat = 76

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.34, style: .continuous)
                .fill(QS.accentSoft)
            Image(systemName: "leaf.fill")
                .font(.system(size: size * 0.40, weight: .regular))
                .foregroundStyle(QS.accent)
                .rotationEffect(.degrees(-12))
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

/// 输入框。snapshot 模式下改用静态文本，这样不依赖 AppKit 控件也能导出预览图。
struct SoftField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var secure: Bool = false
    var reveal: Binding<Bool>? = nil
    var snapshot: Bool = false

    @State private var isComposing = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(QS.sub)
                .frame(width: 22, height: 22)

            Group {
                if snapshot {
                    Text(LocalizedStringKey(display))
                        .foregroundStyle(text.isEmpty ? QS.sub.opacity(0.7) : QS.ink)
                } else {
                    ZStack(alignment: .leading) {
                        if text.isEmpty && !isComposing {
                            Text(LocalizedStringKey(placeholder))
                                .foregroundStyle(QS.sub.opacity(0.7))
                                .lineLimit(1)
                                .allowsHitTesting(false)
                        }

                        if secure && !(reveal?.wrappedValue ?? false) {
                            IMEPlatformTextField(
                                text: $text,
                                isComposing: $isComposing,
                                isSecure: true,
                                placeholder: placeholder,
                                textColor: NSColor(QS.ink)
                            )
                            .id("secure")
                        } else {
                            IMEPlatformTextField(
                                text: $text,
                                isComposing: $isComposing,
                                isSecure: false,
                                placeholder: placeholder,
                                textColor: NSColor(QS.ink)
                            )
                            .id("plain")
                        }
                    }
                }
            }
            .font(.qs(17))
            .frame(maxWidth: .infinity, alignment: .leading)

            if let reveal, secure {
                Button {
                    reveal.wrappedValue.toggle()
                } label: {
                    Image(systemName: reveal.wrappedValue ? "eye.slash" : "eye")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(QS.sub)
                        .frame(width: 26, height: 26)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(reveal.wrappedValue ? "隐藏密码" : "显示密码")
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 54)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(QS.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(QS.border, lineWidth: 1)
        )
    }

    private var display: String {
        if text.isEmpty { return placeholder }
        if secure && !(reveal?.wrappedValue ?? false) {
            return String(repeating: "•", count: text.count)
        }
        return text
    }
}

/// 一行错误提示，占位固定高度，出现时页面不跳动。
struct InlineError: View {
    let text: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 13, weight: .medium))
            Text(LocalizedStringKey(text))
                .font(.qs(13, .medium))
        }
        .foregroundStyle(QS.error)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 18)
        .opacity(text.isEmpty ? 0 : 1)
    }
}

/// 说明这个界面是“感官友好”的小标签。
struct SensoryChip: View {
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(QS.accent)
                .frame(width: 5, height: 5)
            Text("低刺激界面 · 轻动效")
                .font(.qs(12, .medium))
        }
        .foregroundStyle(QS.sub)
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(Capsule().fill(QS.chip))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("低刺激界面，没有动画")
    }
}

/// 主按钮，统一高度与圆角。
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.qs(17, .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(QS.accent.opacity(configuration.isPressed ? 0.82 : 1))
            )
    }
}


/// 低调的制作署名，放在登录页和主页底部。
struct CreditMark: View {
    var body: some View {
        Text("由 Fantôme 制作")
            .font(.qs(10))
            .foregroundStyle(QS.sub.opacity(0.55))
            .accessibilityLabel(Text("由 Fantôme 制作"))
    }
}
