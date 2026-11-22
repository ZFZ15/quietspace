import SwiftUI

struct DesktopSidebar: View {
    @EnvironmentObject private var model: SessionStore

    @Binding var screen: HomeScreen
    var onLogout: () -> Void
    var onStartOnboarding: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                QSLogo(size: 36)
                VStack(alignment: .leading, spacing: 1) {
                    Text("静界")
                        .font(.qs(17, .semibold))
                        .foregroundStyle(QS.ink)
                    Text("QuietSpace")
                        .font(.system(size: 9, weight: .medium, design: .rounded))
                        .foregroundStyle(QS.sub)
                }
            }
            .padding(.top, 46)

            Spacer().frame(height: 34)

            navButton(.home, title: "今日计划", icon: "calendar")
            navButton(.account, title: "账号", icon: "person")
            navButton(.settings, title: "设置", icon: "gearshape")

            Spacer()

            if !model.profile.completed {
                Button(action: onStartOnboarding) {
                    HStack(spacing: 6) {
                        Image(systemName: "checklist")
                            .font(.system(size: 12, weight: .medium))
                        Text("开始自测")
                            .font(.qs(12, .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .background(
                        RoundedRectangle(cornerRadius: 11, style: .continuous)
                            .fill(QS.accent)
                    )
                }
                .buttonStyle(.plain)
                .padding(.bottom, 14)
            }

            Rectangle()
                .fill(QS.border)
                .frame(height: 1)
                .padding(.bottom, 14)

            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(QS.accentSoft)
                        .frame(width: 32, height: 32)
                    Text(String(model.account.prefix(1)).uppercased())
                        .font(.qs(13, .semibold))
                        .foregroundStyle(QS.accent)
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text(model.account)
                        .font(.qs(12, .medium))
                        .foregroundStyle(QS.ink)
                        .lineLimit(1)
                    Text("本地账号")
                        .font(.qs(10))
                        .foregroundStyle(QS.sub)
                }

                Spacer()

                Button(action: onLogout) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(QS.sub)
                        .frame(width: 30, height: 30)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("退出登录")
            }
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 18)
        .frame(width: 232)
        .frame(maxHeight: .infinity)
        .background(QS.surface)
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(QS.border)
                .frame(width: 1)
        }
    }

    private func navButton(_ target: HomeScreen, title: LocalizedStringKey, icon: String) -> some View {
        Button {
            screen = target
        } label: {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                Text(title)
                    .font(.qs(13, .medium))
                Spacer()
            }
            .foregroundStyle(screen == target ? QS.accent : QS.sub)
            .padding(.horizontal, 12)
            .frame(height: 42)
            .background(
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(screen == target ? QS.accentSoft : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .padding(.bottom, 4)
    }
}
