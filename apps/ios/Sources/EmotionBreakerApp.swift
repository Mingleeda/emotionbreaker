import SwiftUI

@main
struct EmotionBreakerApp: App {
    @StateObject private var flow = FlowStore()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $flow.path) {
                HomeView()
                    .navigationDestination(for: Route.self) { route in
                        destination(for: route)
                    }
            }
            .environmentObject(flow)
            .tint(Color.appPrimary)
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
