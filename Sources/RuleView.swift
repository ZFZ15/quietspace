import SwiftUI

struct RuleView: View {
    var snapshot: Bool = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            QS.bg.ignoresSafeArea()

            if snapshot {
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(QS.accent)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(QS.surface))
                        .overlay(Circle().stroke(QS.border, lineWidth: 1))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("返回")

                Text("评估规则")
                    .font(.qs(20, .semibold))
                    .foregroundStyle(QS.ink)

                Spacer()
            }
            .padding(.top, 22)

            Text("这份结果是怎么来的")
                .font(.qs(24, .semibold))
                .foregroundStyle(QS.ink)
                .padding(.top, 24)

            Text("问卷共 10 题，回想过去 14 天的体验。每题按发生天数选择，分数只用于把体验归入一个大致的区间。")
                .font(.qs(14))
                .foregroundStyle(QS.sub)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 10)

            section(title: "怎么计分") {
                bullet("每题 5 个选项，分别记 0、1、2、3、4 分。")
                bullet("0 天记 0 分；1–2 天记 1 分；3–5 天记 2 分；6–9 天记 3 分；10–14 天记 4 分。")
                bullet("10 题相加，最低 0 分，最高 40 分，每题权重相同。")
                bullet("有题目留空时显示「暂无总分」，只保留已答内容。")
            }

            section(title: "分数区间") {
                bandRow(range: "0 分", text: "本期未报告所列体验")
                bandRow(range: "1–13 分", text: "有部分体验值得回顾")
                bandRow(range: "14–26 分", text: "多项体验或日常影响有记录")
                bandRow(range: "27–40 分", text: "多项体验反复出现")
            }

            section(title: "高信号场景") {
                bullet("总分大于 0 时，会列出分值最高的最多三条回答，同分按题号排序。")
                bullet("这只是帮你回忆具体场景，不代表医学判断。")
            }

            Text("本问卷为感官巢原创自评工具，分值及区间尚未经信效度验证。结果只用于自我回顾和原型反馈，不能替代专业评估。")
                .font(.qs(11))
                .foregroundStyle(QS.sub.opacity(0.85))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 22)
                .padding(.bottom, 12)
        }
        .padding(.horizontal, 28)
    }

    private func section<Content: View>(title: LocalizedStringKey, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.qs(16, .semibold))
                .foregroundStyle(QS.ink)
                .padding(.top, 24)
            content()
        }
    }

    private func bullet(_ text: LocalizedStringKey) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(QS.accent.opacity(0.6))
                .frame(width: 4, height: 4)
                .padding(.top, 7)
            Text(text)
                .font(.qs(13))
                .foregroundStyle(QS.sub)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func bandRow(range: LocalizedStringKey, text: LocalizedStringKey) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(range)
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundStyle(QS.accent)
                .frame(width: 100, alignment: .leading)
            Text(text)
                .font(.qs(13))
                .foregroundStyle(QS.sub)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(.vertical, 2)
    }
}
