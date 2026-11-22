import SwiftUI

struct RegisterView: View {
    @ObservedObject private var store: AccountStore
    private let snapshot: Bool
    private let onSuccess: (String) -> Void
    private let onCancel: () -> Void

    @State private var account = ""
    @State private var password = ""
    @State private var confirm = ""
    @State private var errorText = ""

    init(
        store: AccountStore,
        snapshot: Bool = false,
        onSuccess: @escaping (String) -> Void = { _ in },
        onCancel: @escaping () -> Void = {}
    ) {
        _store = ObservedObject(wrappedValue: store)
        self.snapshot = snapshot
        self.onSuccess = onSuccess
        self.onCancel = onCancel
    }

    var body: some View {
        ZStack {
            QS.bg.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center) {
                    Text("创建账号")
                        .font(.qs(26, .semibold))
                        .foregroundStyle(QS.ink)

                    Spacer()

                    Button(action: onCancel) {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(QS.sub)
                            .frame(width: 30, height: 30)
                            .background(Circle().fill(QS.chip))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("关闭")
                }

                Text("只需要一个账号名和密码，之后可以随时回来。")
                    .font(.qs(14))
                    .foregroundStyle(QS.sub)
                    .padding(.top, 10)

                Spacer().frame(height: 30)

                SoftField(
                    icon: "person",
                    placeholder: "账号",
                    text: $account,
                    snapshot: snapshot
                )

                SoftField(
                    icon: "lock",
                    placeholder: "密码（至少 6 位）",
                    text: $password,
                    secure: true,
                    snapshot: snapshot
                )
                .padding(.top, 12)

                SoftField(
                    icon: "lock.rotation",
                    placeholder: "再输入一次密码",
                    text: $confirm,
                    secure: true,
                    snapshot: snapshot
                )
                .padding(.top, 12)

                InlineError(text: errorText)
                    .padding(.top, 10)

                Button(action: submit) {
                    Text("创建并登录")
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.top, 8)

                HStack(spacing: 5) {
                    Text("已经有账号了？")
                        .foregroundStyle(QS.sub)
                    Button("返回登录") {
                        onCancel()
                    }
                    .buttonStyle(.plain)
                    .fontWeight(.semibold)
                    .foregroundStyle(QS.accent)
                }
                .font(.qs(14))
                .frame(maxWidth: .infinity)
                .padding(.top, 20)

                Spacer(minLength: 12)

                Text("账号仅保存在这台设备上，用于原型演示。")
                    .font(.qs(11))
                    .foregroundStyle(QS.sub.opacity(0.8))
            }
            .padding(28)
        }
    }

    private func submit() {
        errorText = ""
        let name = account.trimmingCharacters(in: .whitespacesAndNewlines)
        if let message = store.register(account: name, password: password, confirm: confirm) {
            errorText = message
            return
        }
        onSuccess(name)
    }
}
