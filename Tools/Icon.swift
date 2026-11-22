import SwiftUI
import AppKit

@main
struct IconTool {
    @MainActor
    static func main() {
        let path = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "icon.png"

        let icon = ZStack {
            RoundedRectangle(cornerRadius: 228, style: .continuous)
                .fill(QS.bg)
                .padding(88)

            RoundedRectangle(cornerRadius: 170, style: .continuous)
                .fill(QS.accentSoft)
                .padding(188)

            Image(systemName: "leaf.fill")
                .font(.system(size: 330, weight: .regular))
                .foregroundStyle(QS.accent)
                .rotationEffect(.degrees(-12))
        }
        .frame(width: 1024, height: 1024)

        let renderer = ImageRenderer(content: icon)
        renderer.scale = 1
        renderer.isOpaque = false

        guard
            let image = renderer.nsImage,
            let tiff = image.tiffRepresentation,
            let rep = NSBitmapImageRep(data: tiff),
            let png = rep.representation(using: .png, properties: [:])
        else {
            print("icon render failed")
            return
        }
        try? png.write(to: URL(fileURLWithPath: path))
        print("wrote \(path)")
    }
}
