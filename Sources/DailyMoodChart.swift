import SwiftUI

struct DailyMoodChart: View {
    let events: [PlanEvent]

    private struct Point {
        let minutes: Int
        let score: Int
        let zone: SensoryZone
    }

    private var points: [Point] {
        events.compactMap { event in
            guard let score = SensoryScoring.eventScore(for: event) else { return nil }
            return Point(
                minutes: minutes(from: event.time),
                score: score,
                zone: SensoryZone.zone(for: score)
            )
        }
        .sorted { $0.minutes < $1.minutes }
    }

    var body: some View {
        GeometryReader { geo in
            let left: CGFloat = 46
            let right: CGFloat = 10
            let top: CGFloat = 8
            let bottom: CGFloat = 20
            let width = max(geo.size.width - left - right, 1)
            let height = max(geo.size.height - top - bottom, 1)

            let domain = timeDomain()
            let ticks = tickMinutes(from: domain.lowerBound, to: domain.upperBound)

            let x: (Int) -> CGFloat = { minutes in
                left + width * CGFloat(minutes - domain.lowerBound) / CGFloat(max(domain.upperBound - domain.lowerBound, 1))
            }
            let y: (Int) -> CGFloat = { score in
                top + height * (1 - CGFloat(score) / 100)
            }

            ZStack(alignment: .topLeading) {
                // 时间刻度
                ForEach(ticks, id: \.self) { tick in
                    Path { path in
                        path.move(to: CGPoint(x: x(tick), y: top))
                        path.addLine(to: CGPoint(x: x(tick), y: top + height))
                    }
                    .stroke(QS.border.opacity(0.55), lineWidth: 0.8)

                    Text(clock(tick))
                        .font(.system(size: 8, weight: .medium, design: .rounded))
                        .foregroundStyle(QS.sub)
                        .position(x: x(tick), y: geo.size.height - 7)
                }

                // 坐标轴
                Path { path in
                    path.move(to: CGPoint(x: left, y: top))
                    path.addLine(to: CGPoint(x: left, y: top + height))
                    path.addLine(to: CGPoint(x: left + width, y: top + height))
                }
                .stroke(QS.border, lineWidth: 1)

                // 三个负荷区间，不直接显示分数
                ForEach(SensoryZone.allCases) { zone in
                    let upperScore = zone == .overload ? 100 : (zone == .tense ? 69 : 39)
                    let lowerScore = zone == .overload ? 70 : (zone == .tense ? 40 : 0)
                    let upperY = y(upperScore)
                    let lowerY = y(lowerScore)
                    let rect = CGRect(x: left, y: upperY, width: width, height: max(lowerY - upperY, 1))
                    Path(rect).fill(zone.color.opacity(0.07))

                    Text(zone.title)
                        .font(.system(size: 7.5, weight: .medium))
                        .foregroundStyle(zone.color.opacity(0.95))
                        .position(x: left - 24, y: (upperY + lowerY) / 2)
                }

                ForEach([40, 70], id: \.self) { threshold in
                    Path { path in
                        path.move(to: CGPoint(x: left, y: y(threshold)))
                        path.addLine(to: CGPoint(x: left + width, y: y(threshold)))
                    }
                    .stroke(QS.border, style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                }

                // 折线
                Path { path in
                    for (index, point) in points.enumerated() {
                        let cg = CGPoint(x: x(point.minutes), y: y(point.score))
                        if index == 0 { path.move(to: cg) } else { path.addLine(to: cg) }
                    }
                }
                .stroke(QS.accent, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))

                // 数据点
                ForEach(Array(points.enumerated()), id: \.offset) { _, point in
                    Circle()
                        .fill(point.zone.color)
                        .frame(width: 7, height: 7)
                        .position(x: x(point.minutes), y: y(point.score))
                }
            }
        }
    }

    /// 横轴留出边距，并尽量落在整点/半点上，避免只有两个点时贴在左右边缘。
    private func timeDomain() -> ClosedRange<Int> {
        guard let first = points.first, let last = points.last else { return 0...120 }

        let rawSpan = max(last.minutes - first.minutes, 0)
        var padding = max(30, Int(Double(rawSpan) * 0.25))
        if rawSpan < 120 { padding = max(padding, 60) }

        var lower = max(0, first.minutes - padding)
        var upper = min(1439, last.minutes + padding)

        if upper - lower < 120 {
            let center = (lower + upper) / 2
            lower = max(0, center - 60)
            upper = min(1439, center + 60)
        }

        // 贴着 0 点或 24 点时，把不足的边距补到另一侧。
        if lower == 0 { upper = min(1439, upper + padding) }
        if upper == 1439 { lower = max(0, lower - padding) }

        return lower...max(upper, lower + 1)
    }

    /// 选择 3–5 个时间刻度，让横轴有稳定的节奏。
    private func tickMinutes(from lower: Int, to upper: Int) -> [Int] {
        let span = max(upper - lower, 1)
        let steps = [30, 60, 120, 180, 240, 360]
        var step = steps.last!

        for candidate in steps {
            let first = Int(ceil(Double(lower) / Double(candidate))) * candidate
            guard first <= upper else { continue }
            let count = (upper - first) / candidate + 1
            if count >= 3 && count <= 5 {
                step = candidate
                break
            }
        }

        var ticks: [Int] = []
        var tick = Int(ceil(Double(lower) / Double(step))) * step
        while tick <= upper {
            ticks.append(tick)
            tick += step
        }

        if ticks.isEmpty { ticks = [lower, upper] }
        return ticks
    }

    private func clock(_ minutes: Int) -> String {
        String(format: "%02d:%02d", minutes / 60, minutes % 60)
    }

    private func minutes(from time: String) -> Int {
        let parts = time.split(separator: ":")
        let hour = Int(parts.first ?? "0") ?? 0
        let minute = parts.count > 1 ? (Int(parts[1]) ?? 0) : 0
        return hour * 60 + minute
    }
}
