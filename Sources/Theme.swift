import SwiftUI

/// 静界的颜色与排版基调。
/// 原则：低饱和、无渐变、无强对比闪烁，文字与背景保持足够对比度。
enum QSPalette: String, CaseIterable, Identifiable {
    case green
    case red
    case pink
    case blue
    case yellow

    var id: String { rawValue }

    var title: LocalizedStringKey {
        switch self {
        case .green: return "绿色系"
        case .red: return "红色系"
        case .pink: return "粉色系"
        case .blue: return "蓝色系"
        case .yellow: return "黄色系"
        }
    }

    fileprivate var colors: PaletteColors {
        switch self {
        case .green:
            return PaletteColors(
                bg: Color(hex: 0xF6F3ED),
                surface: Color(hex: 0xFDFCF9),
                ink: Color(hex: 0x2B2A27),
                sub: Color(hex: 0x6F6A62),
                accent: Color(hex: 0x5E7C6A),
                accentSoft: Color(hex: 0xE7EEE9),
                border: Color(hex: 0xE2DCD1),
                chip: Color(hex: 0xEDE8DE)
            )
        case .red:
            return PaletteColors(
                bg: Color(hex: 0xF8F2EE),
                surface: Color(hex: 0xFDFAF8),
                ink: Color(hex: 0x2E2926),
                sub: Color(hex: 0x72675F),
                accent: Color(hex: 0xA45F52),
                accentSoft: Color(hex: 0xF2E3DE),
                border: Color(hex: 0xE6D6CF),
                chip: Color(hex: 0xEFE4DD)
            )
        case .pink:
            return PaletteColors(
                bg: Color(hex: 0xF9F2F3),
                surface: Color(hex: 0xFDFAFB),
                ink: Color(hex: 0x2E282A),
                sub: Color(hex: 0x74676C),
                accent: Color(hex: 0xAE6C7F),
                accentSoft: Color(hex: 0xF3E4E9),
                border: Color(hex: 0xE7D7DD),
                chip: Color(hex: 0xF0E5E8)
            )
        case .blue:
            return PaletteColors(
                bg: Color(hex: 0xF1F4F7),
                surface: Color(hex: 0xFBFCFD),
                ink: Color(hex: 0x282B2F),
                sub: Color(hex: 0x66707A),
                accent: Color(hex: 0x5B7896),
                accentSoft: Color(hex: 0xE3EBF2),
                border: Color(hex: 0xD8E0E8),
                chip: Color(hex: 0xE8EDF2)
            )
        case .yellow:
            return PaletteColors(
                bg: Color(hex: 0xF8F4E9),
                surface: Color(hex: 0xFDFBF5),
                ink: Color(hex: 0x2D2A24),
                sub: Color(hex: 0x716A5C),
                accent: Color(hex: 0xA4853F),
                accentSoft: Color(hex: 0xF3EAD5),
                border: Color(hex: 0xE6DDC7),
                chip: Color(hex: 0xEFE8D8)
            )
        }
    }

    var bg: Color { colors.bg }
    var surface: Color { colors.surface }
    var ink: Color { colors.ink }
    var sub: Color { colors.sub }
    var accent: Color { colors.accent }
    var accentSoft: Color { colors.accentSoft }
    var border: Color { colors.border }
    var chip: Color { colors.chip }
}

private struct PaletteColors {
    let bg: Color
    let surface: Color
    let ink: Color
    let sub: Color
    let accent: Color
    let accentSoft: Color
    let border: Color
    let chip: Color
}

enum QS {
    static let paletteKey = "quietspace.palette"

    static var current: QSPalette {
        let raw = UserDefaults.standard.string(forKey: paletteKey) ?? QSPalette.green.rawValue
        return QSPalette(rawValue: raw) ?? .green
    }

    static var bg: Color { current.bg }
    static var surface: Color { current.surface }
    static var ink: Color { current.ink }
    static var sub: Color { current.sub }
    static var accent: Color { current.accent }
    static var accentSoft: Color { current.accentSoft }
    static var border: Color { current.border }
    static var chip: Color { current.chip }
    static let error = Color(hex: 0xB25C4C)
}

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: 1.0
        )
    }
}

extension Font {
    static func qs(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}
