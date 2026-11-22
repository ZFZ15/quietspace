import SwiftUI

struct LoginView: View {
    @ObservedObject private var store: AccountStore
    private let snapshot: Bool
    private let onLogin: (String) -> Void
    private let onRegister: () -> Void

    @State private var account: String
    @State private var password: String
    @State private var revealPassword = false
    @State private var errorText = ""
    @State private var showResetHint = false

    init(
        store: AccountStore,
        snapshot: Bool = false,
        demoFill: Bool = false,
        onLogin: @escaping (String) -> Void = { _ in },
        onRegister: @escaping () -> Void = {}
    ) {
        _store = ObservedObject(wrappedValue: store)
        self.snapshot = snapshot
        self.onLogin = onLogin
        self.onRegister = onRegister
        _account = State(initialValue: demoFill ? "demo" : "")
        _password = State(initialValue: demoFill ? "123456" : "")
    }

    var body: some View {
        ZStack {
            QS.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer().frame(height: 58)

                QSLogo(size: 76)

                Text("静界")
                    .font(.qs(32, .semibold))
                    .foregroundStyle(QS.ink)
                    .padding(.top, 18)

                Text("给感官敏感的你，一处安静的地方")
                    .font(.qs(14))
                    .foregroundStyle(QS.sub)
                    .padding(.top, 8)

                SensoryChip()
                    .padding(.top, 16)

                Spacer().frame(height: 44)

                SoftField(
                    icon: "person",
                    placeholder: "账号",
                    text: $account,
                    snapshot: snapshot
                )

                SoftField(
                    icon: "lock",
                    placeholder: "密码",
                    text: $password,
                    secure: true,
                    reveal: $revealPassword,
                    snapshot: snapshot
                )
                .padding(.top, 12)

                HStack {
                    Spacer()
                    Button("忘记密码？") {
                        showResetHint = true
                    }
                    .buttonStyle(.plain)
                    .font(.qs(13))
                    .foregroundStyle(QS.sub)
                }
                .padding(.top, 10)

                InlineError(text: errorText)
                    .padding(.top, 8)

                Button(action: submit) {
                    Text("登录")
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.top, 10)

                HStack(spacing: 5) {
                    Text("还没有账号？")
                        .foregroundStyle(QS.sub)
                    Button("注册新账号") {
                        onRegister()
                    }
                    .buttonStyle(.plain)
                    .fontWeight(.semibold)
                    .foregroundStyle(QS.accent)
                }
                .font(.qs(14))
                .padding(.top, 20)

                Spacer(minLength: 12)

                Text("演示账号 demo · 密码 123456")
                    .font(.qs(11))
                    .foregroundStyle(QS.sub.opacity(0.8))

                CreditMark()
                    .padding(.top, 10)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 20)
            .overlay(alignment: .topTrailing) {
                CompanionSprite(size: 58, animated: !snapshot)
                    .padding(.top, 24)
                    .padding(.trailing, 28)
            }
        }
        .alert(Text(L10n.t("重置密码")), isPresented: $showResetHint) {
            Button(L10n.t("知道了"), role: .cancel) {}
        } message: {
            Text(L10n.t("这是原型演示，请联系管理员重置密码。"))
        }
    }

    private func submit() {
        errorText = ""
        let name = account.trimmingCharacters(in: .whitespacesAndNewlines)
        if name.isEmpty {
            errorText = "请先填写账号"
            return
        }
        if password.isEmpty {
            errorText = "请先填写密码"
            return
        }
        if store.login(account: name, password: password) {
            onLogin(name)
        } else {
            errorText = "账号或密码不正确，请再试一次"
        }
    }
}
