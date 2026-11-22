import SwiftUI

struct MoodTrendView: View {
    let days: [MoodDay]

    private struct TrendPoint: Identifiable {
        let index: Int
        let score: Int
        var id: Int { index }
        var zone: SensoryZone { SensoryZone.zone(for: score) }
    }

    private var points: [TrendPoint] {
        days.enumerated().compactMap { index, day in
            day.score.map { TrendPoint(index: index, score: $0) }
        }
    }

    private var latest: TrendPoint? { points.last }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text("近 7 天感官负荷")
                    .font(.qs(13, .semibold))
                    .foregroundStyle(QS.ink)

                Spacer()

                if let latest {
                    Text(latest.zone.title)
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(latest.zone.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(latest.zone.color.opacity(0.13)))
                } else {
                    Text("仅统计已生成报告")
                        .font(.qs(10))
                        .foregroundStyle(QS.sub)
                }
            }

            if points.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "chart.xyaxis.line")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(QS.sub)
                    Text("生成第一份今日报告后，这里会显示近 7 天的感官负荷。")
                        .font(.qs(11))
                        .foregroundStyle(QS.sub)
                        .lineSpacing(2)
                }
                .frame(maxWidth: .infinity, minHeight: 66, alignment: .leading)
            } else {
                GeometryReader { geo in
                    let left: CGFloat = 44
                    let right: CGFloat = 8
                    let top: CGFloat = 8
                    let bottom: CGFloat = 10
                    let width = max(geo.size.width - left - right, 1)
                    let height = max(geo.size.height - top - bottom, 1)
                    let lastIndex = max(days.count - 1, 1)

                    let x: (Int) -> CGFloat = { index in
                        left + width * CGFloat(index) / CGFloat(lastIndex)
                    }
                    let y: (Int) -> CGFloat = { score in
                        top + height * (1 - CGFloat(score) / 100)
                    }

                    ZStack {
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
                                .position(x: left - 23, y: (upperY + lowerY) / 2)
                        }

                        ForEach([40, 70], id: \.self) { threshold in
                            Path { path in
                                path.move(to: CGPoint(x: left, y: y(threshold)))
                                path.addLine(to: CGPoint(x: left + width, y: y(threshold)))
                            }
                            .stroke(QS.border, style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                        }

                        Path { path in
                            var previousIndex: Int?
                            for point in points {
                                let cg = CGPoint(x: x(point.index), y: y(point.score))
                                if let previousIndex, point.index - previousIndex == 1 {
                                    path.addLine(to: cg)
                                } else {
                                    path.move(to: cg)
                                }
                                previousIndex = point.index
                            }
                        }
                        .stroke(
                            QS.accent,
                            style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
                        )

                        ForEach(points) { point in
                            Circle()
                                .fill(point.zone.color)
                                .frame(width: point.index == days.count - 1 ? 8 : 6,
                                       height: point.index == days.count - 1 ? 8 : 6)
                                .position(x: x(point.index), y: y(point.score))
                        }
                    }
                }
                .frame(height: 82)

                HStack(spacing: 0) {
                    ForEach(days) { day in
                        Text(day.date, format: .dateTime.weekday(.narrow))
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundStyle(Calendar.current.isDateInToday(day.date) ? QS.accent : QS.sub)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(QS.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(QS.border, lineWidth: 1)
        )
    }
}
