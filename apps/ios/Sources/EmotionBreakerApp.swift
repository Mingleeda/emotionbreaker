import SwiftUI

@main
struct EmotionBreakerApp: App {
    @StateObject private var flow = FlowStore()
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                NavigationStack(path: $flow.path) {
                    HomeView()
                        .navigationDestination(for: Route.self) { route in
                            destination(for: route)
                        }
                }
                .environmentObject(flow)
                .tint(Color.appPrimary)

                if showSplash {
                    SplashView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .task {
                try? await Task.sleep(for: .seconds(1.2))
                withAnimation(.easeOut(duration: 0.45)) {
                    showSplash = false
                }
            }
        }
    }

    @ViewBuilder
    private func destination(for route: Route) -> some View {
        switch route {
        case .start:
            StartView()
        case .input:
            InputView()
        case .voice:
            VoiceView()
        case .intensity:
            IntensityView()
        case .breakRoutine:
            BreakView()
        case .reassess:
            ReassessView()
        case .analysis:
            AnalysisView()
        case .rewrite:
            RewriteView()
        case .resources:
            ResourcesView()
        case .history:
            HistoryView()
        case .historyDetail(let id):
            HistoryDetailView(sessionID: id)
        }
    }
}

/// 런치 스크린(UILaunchScreen)과 동일한 구성의 인앱 스플래시.
/// 런치 스크린이 스치듯 지나가는 것을 잠깐 이어받아 하나의 스플래시처럼 보이게 한다.
private struct SplashView: View {
    @State private var breathing = false

    var body: some View {
        ZStack {
            Color("LaunchBackground")
                .ignoresSafeArea()
            Image("LaunchDuri")
                .scaleEffect(breathing ? 1.03 : 1.0)
                .animation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true), value: breathing)
        }
        .onAppear { breathing = true }
        .accessibilityHidden(true)
    }
}
