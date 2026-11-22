import Foundation

/// 弹窗等系统组件不一定继承 SwiftUI 的 locale 环境，
/// 这里直接按当前语言读取 en.lproj，保证标题、按钮和正文一致。
enum L10n {
    static var isEnglish: Bool {
        UserDefaults.standard.string(forKey: "quietspace.language") == "en"
    }

    private static let englishBundle: Bundle? = {
        guard let path = Bundle.main.path(forResource: "en", ofType: "lproj") else { return nil }
        return Bundle(path: path)
    }()

    static func t(_ key: String) -> String {
        guard isEnglish, let englishBundle else { return key }
        return englishBundle.localizedString(forKey: key, value: key, table: nil)
    }
}

import SwiftUI

/// sheet / 弹层在 macOS 上不一定继承根视图的 locale，
/// 在每个 sheet 内容上显式再套一次当前语言。
struct AppLocalizedModifier: ViewModifier {
    @AppStorage("quietspace.language") private var languageRaw = "zh"

    func body(content: Content) -> some View {
        content.environment(
            \.locale,
            Locale(identifier: languageRaw == "en" ? "en" : "zh-Hans")
        )
    }
}

extension View {
    func appLocalized() -> some View {
        modifier(AppLocalizedModifier())
    }
}
