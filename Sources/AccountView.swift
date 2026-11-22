import SwiftUI

struct AccountView: View {
    @EnvironmentObject private var model: SessionStore

    let account: String
    var snapshot: Bool = false
    var onBack: () -> Void = {}
    var onLogout: () -> Void = {}
    var onReassess: () -> Void = {}

    @State private var showResetAlert = false

    private var initial: String {
        String(account.prefix(1)).uppercased()
    }

    var body: some View {
        ZStack {
            QS.bg.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                header

                Spacer().frame(height: 26)

                VStack(spacing: 0) {
                    ZStack {
                        Circle()
                            .fill(QS.accentSoft)
                            .frame(width: 96, height: 96)
                        Text(initial.isEmpty ? "?" : initial)
                            .font(.qs(38, .semibold))
                            .foregroundStyle(QS.accent)
                    }

                    Text(account)
                        .font(.qs(24, .semibold))
                        .foregroundStyle(QS.ink)
                        .padding(.top, 16)

                    Text("ID · \(AccountStore.publicID(for: account))")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundStyle(QS.sub)
                        .padding(.top, 6)

                    completionBadge
                        .padding(.top, 12)
                }
                .frame(maxWidth: .infinity)

                Spacer().frame(height: 30)

                VStack(spacing: 0) {
                    infoRow(icon: "person", title: "昵称", value: account)
                    divider
                    infoRow(icon: "number", title: "账号 ID", value: AccountStore.publicID(for: account), mono: true)
                    divider
                    infoRow(icon: "iphone", title: "登录方式", value: "本机账号")
                }
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(QS.surface)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(QS.border, lineWidth: 1)
                )

                Button {
                    if model.profile.completed {
                        showResetAlert = true
                    } else {
                        onReassess()
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(QS.accent)
                            .frame(width: 22)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(model.profile.completed ? "重新评估感官" : "完成感官自测")
                                .font(.qs(14, .medium))
                                .foregroundStyle(QS.ink)
                            Text(model.profile.completed ? "清除上一次结果，重新做 10 道题" : "完成后解锁每日计划")
                                .font(.qs(11))
                                .foregroundStyle(QS.sub)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(QS.sub)
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 62)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(QS.surface)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(QS.border, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .padding(.top, 12)

                Spacer()

                Button(action: onLogout) {
                    Text("退出登录")
                        .font(.qs(15, .medium))
                        .foregroundStyle(QS.error)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(QS.error.opacity(0.35), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)

                Text("静界 0.1 · 本地原型")
                    .font(.qs(11))
                    .foregroundStyle(QS.sub.opacity(0.8))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 14)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 22)
        }
        .alert(Text(L10n.t("清除上一次自测？")), isPresented: $showResetAlert) {
            Button(L10n.t("清除并重新评估"), role: .destructive) {
                onReassess()
            }
            Button(L10n.t("取消"), role: .cancel) {}
        } message: {
            Text(L10n.t("清除后需要重新完成 10 道题，每日计划会暂时锁定。"))
        }
    }

    private var completionBadge: some View {
        HStack(spacing: 5) {
            if model.profile.completed {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 11, weight: .semibold))
                Text("已完成感官自测")
                    .font(.qs(11, .semibold))
            } else {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 11, weight: .semibold))
                Text("尚未完成感官自测")
                    .font(.qs(11, .semibold))
            }
        }
        .foregroundStyle(model.profile.completed ? QS.accent : Feeling.tense.color)
        .padding(.horizontal, 11)
        .padding(.vertical, 6)
        .background(
            Capsule().fill(
                (model.profile.completed ? QS.accent : Feeling.tense.color).opacity(0.14)
            )
        )
    }

    private var header: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(QS.accent)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(QS.surface))
                    .overlay(Circle().stroke(QS.border, lineWidth: 1))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("返回")

            Text("账号")
                .font(.qs(20, .semibold))
                .foregroundStyle(QS.ink)

            Spacer()
        }
        .padding(.top, 22)
    }

    private func infoRow(icon: String, title: LocalizedStringKey, value: String, mono: Bool = false) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(QS.sub)
                .frame(width: 22)

            Text(title)
                .font(.qs(14))
                .foregroundStyle(QS.sub)

            Spacer()

            Text(LocalizedStringKey(value))
                .font(mono ? .system(size: 13, design: .monospaced) : .qs(14, .medium))
                .foregroundStyle(QS.ink)
                .lineLimit(1)
        }
        .frame(height: 54)
    }

    private var divider: some View {
        Rectangle()
            .fill(QS.border)
            .frame(height: 1)
            .padding(.leading, 34)
    }
}
