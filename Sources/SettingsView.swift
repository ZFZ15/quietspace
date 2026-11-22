import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var model: SessionStore

    var snapshot: Bool = false
    var onBack: () -> Void = {}

    @State private var showPermission = false
    @AppStorage("quietspace.language") private var languageRaw = "zh"
    @AppStorage("quietspace.palette") private var paletteRaw = "green"
    @AppStorage("quietspace.companion") private var companionRaw = CompanionKind.dog.rawValue

    var body: some View {
        ZStack {
            QS.bg.ignoresSafeArea()

            Group {
                if snapshot {
                    settingsContent
                } else {
                    ScrollView(showsIndicators: false) {
                        settingsContent
                    }
                }
            }        }
        .sheet(isPresented: $showPermission) {
            WearablePermissionSheet { allowed in
                if allowed {
                    model.setWearableLinked(true)
                }
                showPermission = false
            }
            .frame(width: 390, height: 640)
            .appLocalized()
        }
    }


    private var settingsContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            Spacer().frame(height: 22)

            Text("之后可以在这里调整界面、提醒和隐私选项。")
                .font(.qs(14))
                .foregroundStyle(QS.sub)
                .lineSpacing(3)

            Spacer().frame(height: 16)

            languageCard

            Spacer().frame(height: 12)

            paletteCard

            Spacer().frame(height: 12)

            companionCard

            Spacer().frame(height: 14)

            VStack(spacing: 0) {
                settingRow(icon: "slider.horizontal.3", title: "感官偏好")
                divider
                settingRow(icon: "bell", title: "通知")
                divider
                settingRow(icon: "lock", title: "隐私")
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

            Text("这些选项还在搭建中。")
                .font(.qs(12))
                .foregroundStyle(QS.sub.opacity(0.8))
                .padding(.top, 10)
                .padding(.leading, 4)

            Text("穿戴设备")
                .font(.qs(16, .semibold))
                .foregroundStyle(QS.ink)
                .padding(.top, 24)
                .padding(.bottom, 10)

            wearableCard

            Text("原型阶段为模拟授权；接入 iOS 后会调用 HealthKit。")
                .font(.qs(10))
                .foregroundStyle(QS.sub.opacity(0.75))
                .padding(.top, 8)
                .padding(.leading, 4)

            Spacer()
        }
        .padding(.horizontal, 28)
        .padding(.bottom, 22)
    }

    private var languageCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "globe")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(QS.sub)
                .frame(width: 22)

            Text("语言")
                .font(.qs(15))
                .foregroundStyle(QS.ink)

            Spacer()

            HStack(spacing: 0) {
                languageOption("中文", code: "zh")
                languageOption("English", code: "en")
            }
            .frame(width: 150)
            .padding(3)
            .background(Capsule().fill(QS.chip))
        }
        .padding(.horizontal, 16)
        .frame(height: 54)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(QS.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(QS.border, lineWidth: 1)
        )
    }

    private var paletteCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("界面配色")
                .font(.qs(14, .semibold))
                .foregroundStyle(QS.ink)

            HStack(spacing: 6) {
                ForEach(QSPalette.allCases) { palette in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            paletteRaw = palette.rawValue
                        }
                    } label: {
                        VStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(palette.accent)
                                    .frame(width: 30, height: 30)

                                if paletteRaw == palette.rawValue {
                                    Circle()
                                        .stroke(QS.ink.opacity(0.75), lineWidth: 1.5)
                                        .frame(width: 36, height: 36)
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                            }
                            .frame(width: 36, height: 36)

                            Text(palette.title)
                                .font(.qs(10))
                                .foregroundStyle(paletteRaw == palette.rawValue ? QS.ink : QS.sub)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text(palette.title))
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(QS.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(QS.border, lineWidth: 1)
        )
    }


    private var companionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("选择你的小伙伴")
                .font(.qs(14, .semibold))
                .foregroundStyle(QS.ink)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3),
                spacing: 10
            ) {
                ForEach(CompanionKind.allCases) { kind in
                    let selected = companionRaw == kind.rawValue
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            companionRaw = kind.rawValue
                        }
                    } label: {
                        VStack(spacing: 5) {
                            CompanionView(kind: kind)
                                .frame(width: 84, height: 84)
                                .opacity(selected ? 1 : 0.78)
                                .padding(6)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(selected ? QS.accentSoft : QS.surface)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(selected ? QS.accent.opacity(0.55) : QS.border, lineWidth: 1)
                                )

                            Text(kind.title)
                                .font(.qs(10))
                                .foregroundStyle(selected ? QS.ink : QS.sub)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text(kind.title))
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(QS.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(QS.border, lineWidth: 1)
        )
    }

    private func languageOption(_ title: LocalizedStringKey, code: String) -> some View {
        Button {
            languageRaw = code
        } label: {
            Text(title)
                .font(.qs(12, .medium))
                .foregroundStyle(languageRaw == code ? .white : QS.sub)
                .frame(maxWidth: .infinity)
                .frame(height: 28)
                .background(
                    Capsule().fill(languageRaw == code ? QS.accent : Color.clear)
                )
        }
        .buttonStyle(.plain)
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

            Text("设置")
                .font(.qs(20, .semibold))
                .foregroundStyle(QS.ink)

            Spacer()
        }
        .padding(.top, 22)
    }

    private var wearableCard: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(QS.accentSoft)
                    .frame(width: 38, height: 38)
                Image(systemName: "applewatch")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(QS.accent)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Apple Watch")
                    .font(.qs(15, .medium))
                    .foregroundStyle(QS.ink)

                HStack(spacing: 5) {
                    Circle()
                        .fill(model.profile.wearableLinked ? QS.accent : QS.sub.opacity(0.35))
                        .frame(width: 5, height: 5)
                    Text(model.profile.wearableLinked ? "已连接 · 心率与活动" : "未连接")
                        .font(.qs(11))
                        .foregroundStyle(QS.sub)
                }
            }

            Spacer()

            Button(model.profile.wearableLinked ? "断开" : "连接") {
                if model.profile.wearableLinked {
                    model.setWearableLinked(false)
                } else {
                    showPermission = true
                }
            }
            .buttonStyle(.plain)
            .font(.qs(12, .semibold))
            .foregroundStyle(model.profile.wearableLinked ? QS.sub : .white)
            .padding(.horizontal, 13)
            .padding(.vertical, 7)
            .background(
                Capsule().fill(model.profile.wearableLinked ? QS.chip : QS.accent)
            )
        }
        .padding(.horizontal, 16)
        .frame(height: 68)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(QS.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(QS.border, lineWidth: 1)
        )
    }

    private func settingRow(icon: String, title: LocalizedStringKey) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(QS.sub)
                .frame(width: 22)

            Text(title)
                .font(.qs(15))
                .foregroundStyle(QS.ink)

            Spacer()

            Text("即将开放")
                .font(.qs(11, .medium))
                .foregroundStyle(QS.sub)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Capsule().fill(QS.chip))
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
