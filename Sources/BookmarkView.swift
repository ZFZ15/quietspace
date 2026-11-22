import SwiftUI

/// 每日报告里的中式书签，用竖排文字代替分数。
struct BookmarkView: View {
    let zone: SensoryZone

    private let paper = Color(hex: 0xF7EEDB)
    private let kraft = Color(hex: 0xD9B98A)
    private let edge = Color(hex: 0xCBB08A)
    private let sealRed = Color(hex: 0xA9483A)
    private let leafGreen = Color(hex: 0x6E8B5E)

    var body: some View {
        ZStack(alignment: .top) {
            BookmarkTassel(color: Color(hex: 0x5B7896))
                .frame(width: 40, height: 26)
                .offset(y: -14)

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    BookmarkLeaf(color: leafGreen)
                        .frame(width: 52, height: 34)
                }
                .frame(height: 46)
                .padding(.horizontal, 14)

                HStack(alignment: .top, spacing: 12) {
                    VerticalGlyphs(
                        text: zone.bookmarkTitle,
                        font: .system(size: 23, weight: .semibold, design: .serif),
                        color: Color(hex: 0x2E2A24),
                        spacing: 3
                    )

                    HStack(alignment: .top, spacing: 10) {
                        ForEach(zone.bookmarkLines, id: \.self) { line in
                            VerticalGlyphs(
                                text: line,
                                font: .system(size: 11, weight: .regular, design: .serif),
                                color: Color(hex: 0x4A443A),
                                spacing: 2
                            )
                        }
                    }
                    .padding(.top, 4)

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .frame(height: 156, alignment: .top)
                .background(kraft)

                HStack {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(sealRed)
                        .frame(width: 24, height: 32)
                        .overlay(
                            Text(zone.seal)
                                .font(.system(size: 14, weight: .semibold, design: .serif))
                                .foregroundStyle(paper)
                        )

                    Spacer()

                    Image(systemName: "leaf")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(leafGreen.opacity(0.8))
                }
                .padding(.horizontal, 16)
                .frame(height: 58)
            }
            .frame(width: 172, height: 258)
            .background(paper)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(edge, lineWidth: 1)
            )
            .overlay(alignment: .leading) {
                Rectangle()
                    .fill(zone.color.opacity(0.75))
                    .frame(width: 3)
                    .padding(.vertical, 10)
                    .padding(.leading, 4)
            }
            .shadow(color: QS.ink.opacity(0.12), radius: 10, y: 5)
            .offset(y: 10)
        }
        .frame(width: 190, height: 280)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(zone.title))
    }
}

private struct VerticalGlyphs: View {
    let text: String
    let font: Font
    let color: Color
    let spacing: CGFloat

    var body: some View {
        VStack(spacing: spacing) {
            ForEach(Array(text.enumerated()), id: \.offset) { _, character in
                Text(String(character))
                    .font(font)
                    .foregroundStyle(color)
            }
        }
    }
}

private struct BookmarkTassel: View {
    let color: Color

    var body: some View {
        Canvas { context, size in
            var path = Path()
            path.move(to: CGPoint(x: size.width / 2, y: size.height))
            path.addCurve(
                to: CGPoint(x: size.width / 2, y: 4),
                control1: CGPoint(x: 2, y: size.height - 6),
                control2: CGPoint(x: 2, y: 4)
            )
            path.addCurve(
                to: CGPoint(x: size.width / 2, y: size.height),
                control1: CGPoint(x: size.width - 2, y: 4),
                control2: CGPoint(x: size.width - 2, y: size.height - 6)
            )
            context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: 2, lineCap: .round))
        }
    }
}

private struct BookmarkLeaf: View {
    let color: Color

    var body: some View {
        Canvas { context, size in
            var branch = Path()
            branch.move(to: CGPoint(x: 4, y: size.height - 6))
            branch.addQuadCurve(
                to: CGPoint(x: size.width - 4, y: 8),
                control: CGPoint(x: size.width * 0.5, y: size.height - 4)
            )
            context.stroke(branch, with: .color(color), style: StrokeStyle(lineWidth: 1.4, lineCap: .round))

            let leaves: [(CGFloat, CGFloat, CGFloat)] = [
                (size.width * 0.34, size.height * 0.42, -0.5),
                (size.width * 0.58, size.height * 0.28, 0.2),
                (size.width * 0.78, size.height * 0.42, 0.7)
            ]
            for (x, y, rotation) in leaves {
                var leaf = Path()
                leaf.move(to: CGPoint(x: x, y: y + 7))
                leaf.addQuadCurve(
                    to: CGPoint(x: x + 9, y: y - 4),
                    control: CGPoint(x: x - 4, y: y - 4)
                )
                leaf.addQuadCurve(
                    to: CGPoint(x: x, y: y + 7),
                    control: CGPoint(x: x + 11, y: y + 4)
                )
                context.fill(
                    leaf.applying(CGAffineTransform(rotationAngle: rotation)),
                    with: .color(color.opacity(0.55))
                )
            }
        }
    }
}
