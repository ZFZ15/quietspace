import SwiftUI

struct SolutionReportView: View {
    let report: SolutionReport
    var snapshot: Bool = false
    var onContinue: () -> Void
    var onOpenRule: () -> Void

    var body: some View {
        ZStack {
            QS.bg.ignoresSafeArea()

            if snapshot {
                content
            } else {
                ScrollView(showsIndicators: false) {
                    content
                }
            }
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("初步解决方案")
                    .font(.qs(26, .semibold))
                    .foregroundStyle(QS.ink)
                Spacer()
                Text("刚刚生成")
                    .font(.qs(11, .medium))
                    .foregroundStyle(QS.accent)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(QS.accentSoft))
            }
            .padding(.top, 26)

            Text("基于过去 14 天的 \(report.answered) 项体验 · 只保存在本机")
                .font(.qs(13))
                .foregroundStyle(QS.sub)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 8)

            Spacer().frame(height: 22)

            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: "sparkles")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(QS.accent)
                Text(LocalizedStringKey(report.band.title))
                    .font(.qs(19, .semibold))
                    .foregroundStyle(QS.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text(LocalizedStringKey(report.band.summary))
                    .font(.qs(14))
                    .foregroundStyle(QS.sub)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(QS.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(QS.border, lineWidth: 1)
            )

            Text("先做这三件事")
                .font(.qs(16, .semibold))
                .foregroundStyle(QS.ink)
                .padding(.top, 26)
                .padding(.bottom, 12)

            VStack(spacing: 10) {
                ForEach(Array(report.band.suggestions.enumerated()), id: \.element.id) { index, item in
                    suggestionCard(index: index + 1, item: item)
                }
            }

            if !report.topItems.isEmpty {
                Text("你的高信号场景")
                    .font(.qs(16, .semibold))
                    .foregroundStyle(QS.ink)
                    .padding(.top, 26)
                    .padding(.bottom, 12)

                FlowChips(items: report.topItems.map { $0.question.short })
            }

            Button(action: onOpenRule) {
                HStack(spacing: 10) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(QS.accent)
                    Text("这份评估是怎么算的？")
                        .font(.qs(14, .medium))
                        .foregroundStyle(QS.ink)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(QS.sub)
                }
                .padding(.horizontal, 16)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(QS.surface)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(QS.border, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .padding(.top, 24)

            Button(action: onContinue) {
                Text("保存方案并继续")
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.top, 20)

            Text("这是自我了解工具，不构成诊断。如果这些体验持续影响上课、出行或休息，可以带着记录咨询校医院或心理中心。")
                .font(.qs(11))
                .foregroundStyle(QS.sub.opacity(0.8))
                .lineSpacing(3)
                .padding(.top, 14)
                .padding(.bottom, 10)
        }
        .padding(.horizontal, 28)
    }

    private func suggestionCard(index: Int, item: QuizSuggestion) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(QS.accentSoft)
                    .frame(width: 30, height: 30)
                Text("\(index)")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(QS.accent)
            }

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 7) {
                    Image(systemName: item.icon)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(QS.accent)
                    Text(LocalizedStringKey(item.title))
                        .font(.qs(15, .semibold))
                        .foregroundStyle(QS.ink)
                }
                Text(LocalizedStringKey(item.body))
                    .font(.qs(13))
                    .foregroundStyle(QS.sub)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
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
    }
}

/// 简单的自动换行标签容器。
struct FlowChips: View {
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 8) {
                    ForEach(row, id: \.self) { text in
                        Text(LocalizedStringKey(text))
                            .font(.qs(12, .medium))
                            .foregroundStyle(QS.accent)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(QS.accentSoft))
                    }
                }
            }
        }
    }

    private var rows: [[String]] {
        stride(from: 0, to: items.count, by: 2).map {
            Array(items[$0..<min($0 + 2, items.count)])
        }
    }
}
