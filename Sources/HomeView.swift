import SwiftUI

enum HomeScreen: Equatable {
    case home
    case account
    case settings
}

struct HomeView: View {
    @EnvironmentObject private var model: SessionStore

    @Binding var screen: HomeScreen
    @AppStorage("quietspace.language") private var languageRaw = "zh"
    @State private var feedback: Feeling?
    @State private var feedbackToken = 0
    var justRegistered: Bool = false
    var snapshot: Bool = false
    var showsChrome: Bool = true
    var onLogout: () -> Void = {}
    var onStartOnboarding: () -> Void = {}

    var body: some View {
        ZStack {
            QS.bg.ignoresSafeArea()

            switch screen {
            case .home:
                home
            case .account:
                AccountView(
                    account: model.account,
                    snapshot: snapshot,
                    onBack: { screen = .home },
                    onLogout: onLogout,
                    onReassess: {
                        model.resetAssessment()
                        screen = .home
                        onStartOnboarding()
                    }
                )
            case .settings:
                SettingsView(
                    snapshot: snapshot,
                    onBack: { screen = .home }
                )
            }
        }
    }

    private var home: some View {
        VStack(alignment: .leading, spacing: 0) {
            if showsChrome {
                header
                Spacer().frame(height: 22)
            } else {
                desktopHeader
                Spacer().frame(height: 26)
            }

            HStack(alignment: .bottom, spacing: 8) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("你好，\(model.account)")
                        .font(.qs(showsChrome ? 28 : 30, .semibold))
                        .foregroundStyle(QS.ink)

                    Text(justRegistered ? "账号已创建，先完成自测再开始。" : "欢迎回来。")
                        .font(.qs(14))
                        .foregroundStyle(QS.sub)
                }

                Spacer(minLength: 8)

                CompanionSprite(size: 60, animated: !snapshot)
                    .padding(.bottom, 2)
            }

            Spacer().frame(height: 14)

            if model.profile.completed {
                MoodTrendView(days: model.recentMoodDays())
                Spacer().frame(height: 14)
            } else {
                Spacer().frame(height: 4)
            }

            if model.profile.completed {
                GeometryReader { geo in
                    DailyPlanView(snapshot: snapshot, onFeedback: { feeling in
                        showFeedback(feeling)
                    })
                    .frame(width: geo.size.width, alignment: .top)
                }
                .frame(maxHeight: .infinity)
            } else {
                onboardingBanner
                lockedPlan
                    .padding(.top, 12)
                Spacer(minLength: 0)
            }

            if showsChrome {
                Spacer().frame(height: 10)

                HStack {
                    Button {
                        screen = .settings
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(QS.accent)
                            .frame(width: 46, height: 46)
                            .background(Circle().fill(QS.surface))
                            .overlay(Circle().stroke(QS.border, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("设置")

                    Spacer()

                    CreditMark()

                    Spacer()

                    languageSwitch
                }
            } else {
                CreditMark()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)
            }
        }
        .padding(.horizontal, showsChrome ? 24 : 44)
        .padding(.top, showsChrome ? 22 : 36)
        .padding(.bottom, 20)
        .frame(maxWidth: showsChrome ? .infinity : 860, alignment: .leading)
        .frame(maxWidth: .infinity)
        .overlay(alignment: .bottom) {
            if let feedback {
                FeelingFeedbackToast(feeling: feedback)
                    .id(feedback)
                    .padding(.horizontal, 24)
                    .padding(.bottom, showsChrome ? 76 : 30)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .allowsHitTesting(false)
            }
        }
    }

    private func showFeedback(_ feeling: Feeling) {
        feedbackToken += 1
        let token = feedbackToken

        withAnimation(.spring(response: 0.34, dampingFraction: 0.86)) {
            feedback = feeling
        }

        let base: Double
        switch feeling {
        case .calm: base = 3.4
        case .tense: base = 4.2
        case .overload: base = 5.2
        }
        let seconds = base + (languageRaw == "en" ? 1.3 : 0)

        Task {
            try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            guard token == feedbackToken else { return }
            withAnimation(.easeOut(duration: 0.26)) {
                feedback = nil
            }
        }
    }

    private var header: some View {
        HStack {
            Button {
                screen = .account
            } label: {
                HStack(spacing: 6) {
                    Text("静界")
                        .font(.qs(18, .semibold))
                        .foregroundStyle(QS.ink)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(QS.sub)
                }
                .padding(.vertical, 8)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("打开账号信息")

            Spacer()

            SensoryChip()
        }
    }

    private var desktopHeader: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("今日计划")
                    .font(.qs(26, .semibold))
                    .foregroundStyle(QS.ink)
                Text("按自己的节奏来。")
                    .font(.qs(13))
                    .foregroundStyle(QS.sub)
            }

            Spacer()

            SensoryChip()
            languageSwitch
        }
    }

    private var languageSwitch: some View {
        HStack(spacing: 0) {
            languageOption("中", code: "zh")
            languageOption("EN", code: "en")
        }
        .padding(2)
        .background(Capsule().fill(QS.surface))
        .overlay(Capsule().stroke(QS.border, lineWidth: 1))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("语言 / Language")
    }

    private func languageOption(_ title: String, code: String) -> some View {
        Button {
            languageRaw = code
        } label: {
            Text(title)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(languageRaw == code ? .white : QS.sub)
                .frame(width: 30, height: 26)
                .background(
                    Capsule().fill(languageRaw == code ? QS.accent : Color.clear)
                )
        }
        .buttonStyle(.plain)
    }

    private var onboardingBanner: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checklist")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(QS.accent)
                .frame(width: 26, height: 26)
                .background(Circle().fill(QS.accentSoft))

            VStack(alignment: .leading, spacing: 4) {
                Text("先完成感官自测")
                    .font(.qs(14, .semibold))
                    .foregroundStyle(QS.ink)
                Text("约 3 分钟 · 10 道题，完成后解锁每日计划。")
                    .font(.qs(11))
                    .foregroundStyle(QS.sub)
                    .lineSpacing(2)
            }

            Spacer(minLength: 0)

            Button("开始") {
                onStartOnboarding()
            }
            .buttonStyle(.plain)
            .font(.qs(12, .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(Capsule().fill(QS.accent))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(QS.accentSoft.opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(QS.accent.opacity(0.25), lineWidth: 1)
        )
    }

    private var lockedPlan: some View {
        VStack(spacing: 10) {
            Image(systemName: "lock")
                .font(.system(size: 22, weight: .light))
                .foregroundStyle(QS.sub)
            Text("每日计划未解锁")
                .font(.qs(15, .semibold))
                .foregroundStyle(QS.ink)
            Text("完成自测后，就可以在这里安排每天的事件、\n记录感受并生成心情报告。")
                .font(.qs(12))
                .foregroundStyle(QS.sub)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
            Button("开始自测") {
                onStartOnboarding()
            }
            .buttonStyle(.plain)
            .font(.qs(13, .semibold))
            .foregroundStyle(QS.accent)
            .padding(.top, 2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(QS.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5, 4]))
                .foregroundStyle(QS.border)
        )
    }
}


struct FeelingFeedbackToast: View {
    let feeling: Feeling

    private var message: String {
        switch feeling {
        case .calm:
            return "很好，保持这个节奏。把让你平稳的做法留给明天。"
        case .tense:
            return "先慢下来：呼气比吸气长一点，肩膀放松，喝口水。"
        case .overload:
            return "先离开一下也没关系。找个安静的地方，做三次慢呼吸，再决定下一步。"
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(feeling.color)
                .frame(width: 8, height: 8)
                .padding(.top, 5)

            VStack(alignment: .leading, spacing: 3) {
                Text(LocalizedStringKey(feeling.title))
                    .font(.qs(12, .semibold))
                    .foregroundStyle(feeling.color)

                Text(LocalizedStringKey(message))
                    .font(.qs(12))
                    .foregroundStyle(QS.ink)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .frame(maxWidth: 340, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(QS.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(feeling.color.opacity(0.28), lineWidth: 1)
        )
        .shadow(color: QS.ink.opacity(0.14), radius: 14, y: 5)
    }
}
