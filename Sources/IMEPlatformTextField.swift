import SwiftUI
import AppKit

/// 用原生 NSTextField 承载输入，额外上报「输入法正在组词」状态。
/// 组词时 SoftField 会隐藏占位提示，避免中文候选与提示文字重叠。
struct IMEPlatformTextField: NSViewRepresentable {
    @Binding var text: String
    @Binding var isComposing: Bool
    var isSecure: Bool
    var placeholder: String
    var fontSize: CGFloat = 17
    var textColor: NSColor = .labelColor

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> NSTextField {
        let field: NSTextField = isSecure ? NSSecureTextField() : NSTextField()
        field.delegate = context.coordinator
        field.isBordered = false
        field.isBezeled = false
        field.drawsBackground = false
        field.focusRingType = .none
        field.font = .systemFont(ofSize: fontSize)
        field.textColor = textColor
        field.placeholderString = nil
        field.stringValue = text
        field.lineBreakMode = .byTruncatingTail
        field.cell?.wraps = false
        field.cell?.isScrollable = true
        field.setContentHuggingPriority(.defaultLow, for: .horizontal)
        field.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        field.setAccessibilityLabel(placeholder)
        return field
    }

    func updateNSView(_ field: NSTextField, context: Context) {
        if field.stringValue != text {
            field.stringValue = text
        }
        field.font = .systemFont(ofSize: fontSize)
        field.textColor = textColor
    }

    final class Coordinator: NSObject, NSTextFieldDelegate {
        private let parent: IMEPlatformTextField

        init(_ parent: IMEPlatformTextField) {
            self.parent = parent
        }

        func controlTextDidBeginEditing(_ obj: Notification) {
            updateComposing(from: obj)
        }

        func controlTextDidChange(_ obj: Notification) {
            guard let field = obj.object as? NSTextField else { return }
            let composing = (field.currentEditor() as? NSTextView)?.hasMarkedText() ?? false

            if parent.isComposing != composing {
                parent.isComposing = composing
            }

            // 组词过程中不写入绑定，等提交后再写；候选文字由原生输入框自己绘制。
            if !composing {
                parent.text = field.stringValue
            }
        }

        func controlTextDidEndEditing(_ obj: Notification) {
            parent.isComposing = false
            if let field = obj.object as? NSTextField {
                parent.text = field.stringValue
            }
        }

        private func updateComposing(from obj: Notification) {
            guard let field = obj.object as? NSTextField else { return }
            let composing = (field.currentEditor() as? NSTextView)?.hasMarkedText() ?? false
            if parent.isComposing != composing {
                parent.isComposing = composing
            }
        }
    }
}
