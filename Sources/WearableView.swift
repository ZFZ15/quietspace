import SwiftUI

/// 模拟 Apple Watch 授权流程；接入 iOS 后会替换成 HealthKit 授权。
struct WearablePermissionSheet: View {
    var onDecision: (Bool) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            QS.bg.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Spacer()
                    Button {
                        onDecision(false)
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(QS.sub)
                            .frame(width: 30, height: 30)
                            .background(Circle().fill(QS.chip))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 20)

                HStack {
                    Spacer()
                    ZStack {
                        Circle()
                            .fill(QS.accentSoft)
                            .frame(width: 92, height: 92)
                        Image(systemName: "applewatch")
                            .font(.system(size: 40, weight: .regular))
                            .foregroundStyle(QS.accent)
                    }
                    Spacer()
                }
                .padding(.top, 18)

                Text("允许静界读取\nApple Watch 数据？")
                    .font(.qs(24, .semibold))
                    .foregroundStyle(QS.ink)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)

                Text("授权后可以读取心率、活动与睡眠数据，帮你把每日计划和身体状态放在一起看。")
                    .font(.qs(13))
                    .foregroundStyle(QS.sub)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 10)
                    .padding(.top, 12)

                VStack(spacing: 10) {
                    permissionRow(icon: "heart", title: "心率", detail: "事件前后的心率变化")
                    permissionRow(icon: "figure.walk", title: "活动", detail: "步数与活动时间")
                    permissionRow(icon: "moon.zzz", title: "睡眠", detail: "夜间睡眠时长")
                }
                .padding(.top, 22)

                Spacer()

                Button {
                    onDecision(true)
                    dismiss()
                } label: {
                    Text("允许")
                }
                .buttonStyle(PrimaryButtonStyle())

                Button {
                    onDecision(false)
                    dismiss()
                } label: {
                    Text("不允许")
                        .font(.qs(14))
                        .foregroundStyle(QS.sub)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                }
                .buttonStyle(.plain)
                .padding(.top, 10)

                Text("原型演示：正式版接入 iOS 后会调用 HealthKit 系统授权。")
                    .font(.qs(10))
                    .foregroundStyle(QS.sub.opacity(0.75))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
                    .padding(.bottom, 10)
            }
            .padding(.horizontal, 28)
        }
    }

    private func permissionRow(icon: String, title: LocalizedStringKey, detail: LocalizedStringKey) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(QS.accent)
                .frame(width: 24)
            Text(title)
                .font(.qs(14, .medium))
                .foregroundStyle(QS.ink)
            Spacer()
            Text(detail)
                .font(.qs(12))
                .foregroundStyle(QS.sub)
        }
        .padding(.horizontal, 16)
        .frame(height: 48)
        .background(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .fill(QS.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .stroke(QS.border, lineWidth: 1)
        )
    }
}
