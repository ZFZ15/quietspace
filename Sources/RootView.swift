import SwiftUI

struct RootView: View {
    @StateObject private var accountStore = AccountStore()

    @State private var session: SessionStore?
    @State private var showRegister = false
    @State private var showOnboarding = false
    @State private var justRegistered = false
    @State private var screen: HomeScreen = .home

    @AppStorage("quietspace.language") private var languageRaw = "zh"
    @AppStorage("quietspace.palette") private var paletteRaw = "green"
    @State private var didAutoLogin = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                QS.bg.ignoresSafeArea()

                if let model = session {
                    if showOnboarding {
                        OnboardingFlowView(
                            onDone: { showOnboarding = false },
                            onClose: { showOnboarding = false }
                        )
                        .environmentObject(model)
                        .frame(maxWidth: 520)
                        .frame(maxWidth: .infinity)
                    } else if geo.size.width >= 820 {
                        HStack(spacing: 0) {
                            DesktopSidebar(
                                screen: $screen,
                                onLogout: logout,
                                onStartOnboarding: { showOnboarding = true }
                            )
                            .environmentObject(model)

                            HomeView(
                                screen: $screen,
                                justRegistered: justRegistered,
                                showsChrome: false,
                                onLogout: logout,
                                onStartOnboarding: { showOnboarding = true }
                            )
                            .environmentObject(model)
                        }
                    } else {
                        HomeView(
                            screen: $screen,
                            justRegistered: justRegistered,
                            onLogout: logout,
                            onStartOnboarding: { showOnboarding = true }
                        )
                        .environmentObject(model)
                        .frame(maxWidth: 560)
                    }
                } else {
                    LoginView(
                        store: accountStore,
                        onLogin: { name in
                            justRegistered = false
                            screen = .home
                            session = SessionStore(account: name)
                        },
                        onRegister: {
                            showRegister = true
                        }
                    )
                    .frame(maxWidth: 520)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .id(paletteRaw)
        }
        .frame(minWidth: 390, minHeight: 700)
        .onAppear {
            guard ProcessInfo.processInfo.arguments.contains("--demo-login"), !didAutoLogin else { return }
            didAutoLogin = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                screen = .home
                session = SessionStore(account: "demo")
            }
        }
        .environment(\.locale, Locale(identifier: languageRaw == "en" ? "en" : "zh-Hans"))
        .tint(QS.accent)
        .sheet(isPresented: $showRegister) {
            RegisterView(
                store: accountStore,
                onSuccess: { name in
                    showRegister = false
                    justRegistered = true
                    screen = .home
                    session = SessionStore(account: name)
                    showOnboarding = true
                },
                onCancel: {
                    showRegister = false
                }
            )
            .frame(width: 390, height: 620)
            .appLocalized()
        }
    }

    private func logout() {
        justRegistered = false
        showOnboarding = false
        screen = .home
        session = nil
    }
}
