import SwiftUI

struct OnboardingFlowView: View {
    @EnvironmentObject private var model: SessionStore

    var onDone: () -> Void
    var onClose: () -> Void

    @State private var step: Step = .intro
    @State private var index = 0
    @State private var answers: [Int?] = Array(repeating: nil, count: 10)
    @State private var showRule = false
    @State private var showWearablePrompt = false
    @State private var showPermission = false
    @State private var isAdvancing = false

    init(onDone: @escaping () -> Void, onClose: @escaping () -> Void, previewQuiz: Bool = false) {
        self.onDone = onDone
        self.onClose = onClose
        _step = State(initialValue: previewQuiz ? .quiz : .intro)
    }

    private enum Step {
        case intro
        case quiz
        case report
    }

    var body: some View {
        ZStack {
            QS.bg.ignoresSafeArea()

            switch step {
            case .intro:
                intro
            case .quiz:
                quiz
            case .report:
                SolutionReportView(
                    report: SolutionReport.build(answers: answers),
                    onContinue: { showWearablePrompt = true },
                    onOpenRule: { showRule = true }
                )
            }
        }
        .alert(Text(L10n.t("连接 Apple Watch？")), isPresented: $showWearablePrompt) {
            Button(L10n.t("连接")) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    showPermission = true
                }
            }
            Button(L10n.t("暂不"), role: .cancel) {
                finish(linked: false)
            }
        } message: {
            Text(L10n.t("连接后可以读取心率与活动数据，帮助你把每日计划和身体状态放在一起看。"))
        }
        .sheet(isPresented: $showPermission) {
            WearablePermissionSheet { allowed in
                showPermission = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    finish(linked: allowed)
                }
            }
            .frame(width: 390, height: 640)
            .appLocalized()
        }
        .sheet(isPresented: $showRule) {
            RuleView()
                .frame(width: 390, height: 760)
                .appLocalized()
        }
    }

    // MARK: - 介绍页

    private var intro: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(QS.sub)
                        .frame(width: 30, height: 30)
                        .background(Circle().fill(QS.chip))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("稍后再说")
            }
            .padding(.top, 24)

            Spacer().frame(height: 36)

            QSLogo(size: 72)

            Text("先了解你的\n感官画像")
                .font(.qs(30, .semibold))
                .foregroundStyle(QS.ink)
                .lineSpacing(4)
                .padding(.top, 22)

            Text("10 道题，大约 3 分钟。结果只保存在这台设备上，用来生成你的初步解决方案。")
                .font(.qs(15))
                .foregroundStyle(QS.sub)
                .lineSpacing(5)
                .padding(.top, 14)

            Spacer().frame(height: 28)

            VStack(alignment: .leading, spacing: 16) {
                introLine(icon: "calendar", text: "回想过去 14 天的真实体验")
                introLine(icon: "checkmark.circle", text: "每题单选，按发生天数作答")
                introLine(icon: "arrow.uturn.left", text: "记不清的题可以跳过")
            }

            Spacer()

            Button {
                step = .quiz
                index = 0
            } label: {
                Text("开始自测")
            }
            .buttonStyle(PrimaryButtonStyle())

            Button("稍后再说") {
                onClose()
            }
            .buttonStyle(.plain)
            .font(.qs(14))
            .foregroundStyle(QS.sub)
            .frame(maxWidth: .infinity)
            .padding(.top, 16)

            Text("本问卷为自我了解工具，不替代专业评估。")
                .font(.qs(11))
                .foregroundStyle(QS.sub.opacity(0.75))
                .frame(maxWidth: .infinity)
                .padding(.top, 18)
                .padding(.bottom, 10)
        }
        .padding(.horizontal, 28)
    }

    private func introLine(icon: String, text: LocalizedStringKey) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(QS.accent)
                .frame(width: 24)
            Text(text)
                .font(.qs(14))
                .foregroundStyle(QS.ink)
        }
    }

    // MARK: - 答题页

    private var quiz: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                Button {
                    if index > 0 {
                        index -= 1
                    } else {
                        step = .intro
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(QS.accent)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(QS.surface))
                        .overlay(Circle().stroke(QS.border, lineWidth: 1))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("上一题")

                Spacer()

                Text("\(index + 1) / \(QuizData.questions.count)")
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundStyle(QS.sub)
            }
            .padding(.top, 24)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(QS.chip)
                    Capsule()
                        .fill(QS.accent)
                        .frame(width: geo.size.width * CGFloat(index + 1) / CGFloat(QuizData.questions.count))
                }
            }
            .frame(height: 5)
            .padding(.top, 16)

            Text(LocalizedStringKey(QuizData.questions[index].section))
                .font(.qs(12, .medium))
                .foregroundStyle(QS.accent)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(QS.accentSoft))
                .padding(.top, 30)

            Text(LocalizedStringKey(QuizData.questions[index].text))
                .font(.qs(24, .semibold))
                .foregroundStyle(QS.ink)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 16)

            Text("过去 14 天里，这种情况出现了多少天？")
                .font(.qs(13))
                .foregroundStyle(QS.sub)
                .padding(.top, 10)

            Spacer().frame(height: 26)

            VStack(spacing: 10) {
                ForEach(Array(QuizData.options.enumerated()), id: \.offset) { offset, label in
                    optionRow(value: offset, label: label)
                }
            }

            Spacer()

            Button("记不清，跳过这题") {
                answers[index] = nil
                advance()
            }
            .buttonStyle(.plain)
            .font(.qs(13))
            .foregroundStyle(QS.sub)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 14)
        }
        .padding(.horizontal, 28)
    }

    private func optionRow(value: Int, label: String) -> some View {
        let selected = answers[index] == value
        return Button {
            choose(value)
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(selected ? QS.accent : QS.border, lineWidth: selected ? 6 : 1)
                        .frame(width: 22, height: 22)
                }
                Text(LocalizedStringKey(label))
                    .font(.qs(16))
                    .foregroundStyle(QS.ink)
                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(selected ? QS.accentSoft : QS.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(selected ? QS.accent : QS.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(label)\(selected ? "，已选择" : "")")
    }

    private func choose(_ value: Int) {
        guard !isAdvancing else { return }
        isAdvancing = true
        answers[index] = value
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
            isAdvancing = false
            advance()
        }
    }

    private func advance() {
        if index < QuizData.questions.count - 1 {
            index += 1
        } else {
            step = .report
        }
    }

    private func finish(linked: Bool) {
        model.finishOnboarding(answers: answers, wearableLinked: linked)
        onDone()
    }
}
