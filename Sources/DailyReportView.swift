import SwiftUI

struct DailyReportView: View {
    let result: MoodResult
    let date: Date
    var events: [PlanEvent] = []
    var snapshot: Bool = false
    var onClose: () -> Void

    private var isStable: Bool { result.zone == .stable }

    private let quotes = [
        "慢一点，也是在照顾自己。",
        "今天已经尽力了，休息不是退步。",
        "把节奏调慢，世界不会因此走远。"
    ]

    @State private var showQuoteDetail = false

    private var quote: String {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        return quotes[day % quotes.count]
    }

    var body: some View {
        ZStack(alignment: .top) {
            QS.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                if snapshot {
                    content
                } else {
                    ScrollView(showsIndicators: false) {
                        content
                    }
                }

                Button("完成") {
                    onClose()
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 26)
                .padding(.top, 10)
                .padding(.bottom, 18)
            }
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            bookmarkSection

            if isStable {
                stableContent
            } else {
                supportiveContent
            }

            dailyChartSection
        }
        .padding(.horizontal, 26)
        .padding(.top, 22)
        .padding(.bottom, 6)
    }

    private var dailyChartSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("今日感官负荷")
                    .font(.qs(13, .semibold))
                    .foregroundStyle(QS.ink)
                Spacer()
                Text("按事件时间")
                    .font(.qs(10))
                    .foregroundStyle(QS.sub)
            }

            DailyMoodChart(events: events)
                .frame(height: 110)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(QS.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(QS.border, lineWidth: 1)
        )
        .padding(.top, 16)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("今日感官报告")
                    .font(.qs(22, .semibold))
                    .foregroundStyle(QS.ink)
                HStack(spacing: 0) {
                    Text(DayKey.monthDay(date))
                    if totalCount == 1 {
                        Text(" · 1 件事")
                    } else {
                        Text(" · 共 \(totalCount) 件事")
                    }
                }
                .font(.qs(11))
                .foregroundStyle(QS.sub)
            }

            Spacer()

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(QS.sub)
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(QS.chip))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("关闭")
        }
    }

    private var totalCount: Int {
        result.counts.values.reduce(0, +)
    }

    private var bookmarkSection: some View {
        VStack(spacing: 8) {
            ZStack {
                if isStable {
                    FireworksView(snapshot: snapshot)
                }

                BookmarkView(zone: result.zone)
            }
            .frame(height: 292)

            Text(result.zone.title)
                .font(.qs(12, .semibold))
                .foregroundStyle(result.zone.color)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Capsule().fill(result.zone.color.opacity(0.13)))

            Text(zoneCaption)
                .font(.qs(12))
                .foregroundStyle(QS.sub)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.horizontal, 18)

            if result.severeCount > 0 {
                Text("有 \(result.severeCount) 件事达到重度过载")
                    .font(.qs(10, .medium))
                    .foregroundStyle(SensoryZone.overload.color)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(SensoryZone.overload.color.opacity(0.10)))
            }

            zoneCounts
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 2)
    }

    private var zoneCaption: LocalizedStringKey {
        switch result.zone {
        case .stable: return "今天的负荷在可承受范围内。"
        case .tense: return "今天有一些时刻接近阈值，先缓一缓。"
        case .overload: return "今天的负荷超出了可调节范围，先照顾自己。"
        }
    }

    private var stableContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("把这份节奏带到明天")
                .font(.qs(13, .semibold))
                .foregroundStyle(QS.ink)

            VStack(alignment: .leading, spacing: 6) {
                Label("提前 5 分钟到场", systemImage: "clock")
                Label("每件事后留一点安静", systemImage: "leaf")
            }
            .font(.qs(11))
            .foregroundStyle(QS.sub)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(QS.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(QS.border, lineWidth: 1)
        )
        .padding(.top, 14)
    }

    private var supportiveContent: some View {
        VStack(spacing: 0) {
            Button {
                showQuoteDetail = true
            } label: {
                VStack(alignment: .leading, spacing: 8) {
                    (Text("「") + Text(LocalizedStringKey(quote)) + Text("」"))
                        .font(.system(size: 17, weight: .medium, design: .serif))
                        .foregroundStyle(QS.ink)
                        .lineSpacing(5)
                        .lineLimit(1)

                    Text("这不是你的错，也不是需要硬扛的一天。先把节奏放慢一点。")
                        .font(.qs(12))
                        .foregroundStyle(QS.sub)
                        .lineSpacing(3)
                        .lineLimit(2)

                    HStack(spacing: 4) {
                        Text("点击查看完整内容")
                            .font(.qs(10, .medium))
                        Image(systemName: "chevron.up.right")
                            .font(.system(size: 8, weight: .semibold))
                    }
                    .foregroundStyle(QS.accent)
                    .padding(.top, 2)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(QS.surface)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(QS.border, lineWidth: 1)
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("查看完整内容")
            .popover(isPresented: $showQuoteDetail, arrowEdge: .bottom) {
                QuoteDetailView(quote: quote)
            }
            .padding(.top, 14)

            Text("明天可以试试")
                .font(.qs(14, .semibold))
                .foregroundStyle(QS.ink)
                .padding(.top, 18)
                .padding(.bottom, 8)

            VStack(spacing: 7) {
                adjustmentRow(icon: "minus.circle", text: "少安排一件高刺激的事")
                adjustmentRow(icon: "pause.circle", text: "每件事后留 10 分钟安静时间")
                adjustmentRow(icon: "headphones", text: "把降噪耳机和「退出信号」带上")
            }

            Text("个性化调整方案会在后续版本接入。")
                .font(.qs(10))
                .foregroundStyle(QS.sub.opacity(0.75))
                .padding(.top, 10)
        }
    }

    private var zoneCounts: some View {
        HStack(spacing: 14) {
            ForEach(SensoryZone.allCases) { zone in
                HStack(spacing: 5) {
                    Circle()
                        .fill(zone.color)
                        .frame(width: 6, height: 6)
                    (Text(zone.title) + Text(" \(result.counts[zone] ?? 0)"))
                        .font(.qs(10, .medium))
                        .foregroundStyle(QS.sub)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func adjustmentRow(icon: String, text: LocalizedStringKey) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(QS.accent)
                .frame(width: 20)
            Text(text)
                .font(.qs(12))
                .foregroundStyle(QS.ink)
            Spacer()
        }
        .padding(.horizontal, 14)
        .frame(height: 40)
        .background(
            RoundedRectangle(cornerRadius: 11, style: .continuous)
                .fill(QS.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 11, style: .continuous)
                .stroke(QS.border, lineWidth: 1)
        )
    }
}

// MARK: - 烟花

struct FireworksView: View {
    var snapshot: Bool = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var start = Date().addingTimeInterval(0.2)
    @State private var running = true

    private struct Particle {
        let angle: Double
        let speed: Double
        let size: Double
        let colorIndex: Int
    }

    private struct Burst {
        let x: Double
        let y: Double
        let delay: Double
        let particles: [Particle]
    }

    private static let palette: [Color] = [
        Color(hex: 0xD98C4A),
        Color(hex: 0xC25B4A),
        Color(hex: 0x6E9B7F),
        Color(hex: 0xE0A458)
    ]

    private let bursts: [Burst] = FireworksView.makeBursts()

    var body: some View {
        Group {
            if snapshot || reduceMotion {
                fireworks(elapsed: 1.25)
            } else {
                TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: !running)) { timeline in
                    fireworks(elapsed: timeline.date.timeIntervalSince(start))
                }
                .task {
                    // 只播放一次，结束后停止 TimelineView，避免报告页持续重绘。
                    try? await Task.sleep(nanoseconds: 4_200_000_000)
                    running = false
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func fireworks(elapsed: Double) -> some View {
        Canvas { context, size in
            for burst in bursts {
                let local = elapsed - burst.delay
                guard local >= 0, local <= 2.4 else { continue }
                let life = local / 2.4
                let origin = CGPoint(x: size.width * burst.x, y: size.height * burst.y)

                if local < 0.3 {
                    let flash = 1 - local / 0.3
                    let r = 26 * flash
                    let rect = CGRect(x: origin.x - r, y: origin.y - r, width: r * 2, height: r * 2)
                    context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(0.45 * flash)))
                }

                for particle in burst.particles {
                    let distance = particle.speed * local
                    let x = origin.x + cos(particle.angle) * distance
                    let y = origin.y + sin(particle.angle) * distance + 58 * local * local
                    let alpha = pow(1 - life, 1.6)
                    let radius = particle.size * (1 - life * 0.45)
                    let color = Self.palette[particle.colorIndex % Self.palette.count]

                    let tail = max(0, local - 0.05)
                    let tailX = origin.x + cos(particle.angle) * particle.speed * tail
                    let tailY = origin.y + sin(particle.angle) * particle.speed * tail + 58 * tail * tail

                    var trail = Path()
                    trail.move(to: CGPoint(x: tailX, y: tailY))
                    trail.addLine(to: CGPoint(x: x, y: y))
                    context.stroke(
                        trail,
                        with: .color(color.opacity(alpha * 0.75)),
                        lineWidth: max(0.6, radius * 0.9)
                    )

                    let glow = CGRect(
                        x: x - radius * 2.4,
                        y: y - radius * 2.4,
                        width: radius * 4.8,
                        height: radius * 4.8
                    )
                    context.fill(Path(ellipseIn: glow), with: .color(color.opacity(alpha * 0.16)))

                    let core = CGRect(
                        x: x - radius,
                        y: y - radius,
                        width: radius * 2,
                        height: radius * 2
                    )
                    context.fill(Path(ellipseIn: core), with: .color(color.opacity(alpha)))
                }
            }
        }
    }

    private static func makeBursts() -> [Burst] {
        var seed: UInt64 = 20261121
        func random() -> Double {
            seed = seed &* 6364136223846793005 &+ 1442695040888963407
            return Double((seed >> 33) % 1000) / 1000.0
        }

        let centers: [(Double, Double, Double)] = [
            (0.28, 0.46, 0.0),
            (0.72, 0.36, 0.55),
            (0.50, 0.52, 1.10)
        ]

        return centers.map { center in
            let particles = (0..<38).map { index -> Particle in
                let base = Double(index) / 38.0 * 2.0 * .pi
                return Particle(
                    angle: base + random() * 0.26,
                    speed: 55 + random() * 95,
                    size: 1.4 + random() * 2.2,
                    colorIndex: Int(random() * 4)
                )
            }
            return Burst(x: center.0, y: center.1, delay: center.2, particles: particles)
        }
    }
}

struct QuoteDetailView: View {
    let quote: String

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            (Text("「") + Text(L10n.t(quote)) + Text("」"))
                .font(.system(size: 20, weight: .medium, design: .serif))
                .foregroundStyle(QS.ink)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)

            Text(L10n.t("这不是你的错，也不是需要硬扛的一天。先把节奏放慢一点。"))
                .font(.qs(13))
                .foregroundStyle(QS.sub)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            Divider()
                .overlay(QS.border)

            Button {
                dismiss()
            } label: {
                Text("关闭")
                    .font(.qs(12, .medium))
                    .foregroundStyle(QS.accent)
                    .frame(maxWidth: .infinity)
                    .frame(height: 34)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(QS.accentSoft)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .frame(width: 340)
        .background(QS.bg)
    }
}
