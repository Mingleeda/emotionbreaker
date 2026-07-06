import SwiftUI

enum Route: Hashable {
    case start
    case input
    case voice
    case intensity
    case breakRoutine
    case reassess
    case analysis
    case rewrite
    case resources
    case history
    case historyDetail(UUID)
}

/// 한 번의 감정 세션 동안의 플로우 상태와 내비게이션을 관리한다.
@MainActor
final class FlowStore: ObservableObject {
    @Published var path: [Route] = []

    @Published var selectedEmotion: SelectedEmotion?
    @Published var inputType: InputType?
    @Published var originalText: String = ""
    @Published var emotionScoreBefore: Int?
    @Published var emotionScoreAfter: Int?
    @Published var analysis: EmotionAnalysisResult?
    @Published var messages: SuggestedMessages?
    @Published var savedSessionID: UUID?

    var sessionStore: SessionStore { SessionStore.shared }

    /// 감정 점수에 따라 다음 화면을 결정한다. 4점 이상이면 60초 브레이크 먼저.
    func routeForScore(_ score: Int) -> Route {
        score >= 4 ? .breakRoutine : .analysis
    }

    func selectScoreBefore(_ score: Int) {
        emotionScoreBefore = score
        emotionScoreAfter = nil
        path.append(routeForScore(score))
    }

    func selectScoreAfter(_ score: Int) {
        emotionScoreAfter = score
        path.append(.analysis)
    }

    private var didRequestRemoteAnalysis = false
    private var didRequestRemoteMessages = false

    /// 분석 화면 진입 시 로컬 분석을 즉시 보여주고, 서버 AI 결과가 오면 교체한다.
    func prepareAnalysis() {
        var result = analysis ?? LocalCoach.makeAnalysis(
            selectedEmotion: selectedEmotion,
            originalText: originalText
        )
        result.riskLevel = LocalCoach.detectRiskLevel(in: originalText)
        analysis = result

        // 위험 표현이 감지되면 일반 AI 코칭을 중단한다.
        guard result.riskLevel == .normal, !didRequestRemoteAnalysis else { return }
        didRequestRemoteAnalysis = true

        let text = originalText
        Task { [weak self] in
            guard let self,
                  var remote = await RemoteCoach.fetchAnalysis(
                      originalText: text,
                      selectedEmotion: self.selectedEmotion,
                      emotionScoreBefore: self.emotionScoreBefore,
                      emotionScoreAfter: self.emotionScoreAfter
                  ),
                  self.originalText == text
            else { return }
            // 위험 감지는 항상 로컬 판정을 우선한다.
            remote.riskLevel = LocalCoach.detectRiskLevel(in: text)
            self.analysis = remote
        }
    }

    /// 문장 추천 화면 진입 시 로컬 추천을 즉시 보여주고, 서버 AI 결과가 오면 교체한다.
    func prepareMessages() {
        if messages == nil {
            messages = LocalCoach.makeSuggestedMessages(
                originalText: originalText,
                analysis: analysis
            )
        }

        guard LocalCoach.detectRiskLevel(in: originalText) == .normal, !didRequestRemoteMessages else { return }
        didRequestRemoteMessages = true

        let text = originalText
        Task { [weak self] in
            guard let self,
                  let remote = await RemoteCoach.fetchMessages(
                      originalText: text,
                      selectedEmotion: self.selectedEmotion,
                      analysis: self.analysis
                  ),
                  self.originalText == text
            else { return }
            self.messages = remote
        }
    }

    /// 사용자가 명시적으로 저장을 선택했을 때만 세션을 기록한다.
    func saveCurrentSession() {
        let session = EmotionSession(
            id: UUID(),
            createdAt: Date(),
            selectedEmotion: selectedEmotion,
            inputType: inputType,
            originalText: originalText,
            emotionScoreBefore: emotionScoreBefore,
            emotionScoreAfter: emotionScoreAfter,
            analysis: analysis,
            messages: messages
        )
        sessionStore.save(session)
        savedSessionID = session.id
    }

    /// 플로우를 종료하고 홈으로 돌아간다. 저장하지 않은 데이터는 버린다.
    func finishFlow() {
        selectedEmotion = nil
        inputType = nil
        originalText = ""
        emotionScoreBefore = nil
        emotionScoreAfter = nil
        analysis = nil
        messages = nil
        savedSessionID = nil
        didRequestRemoteAnalysis = false
        didRequestRemoteMessages = false
        path.removeAll()
    }

    /// 새 입력을 시작할 때 이전 분석 결과를 무효화한다.
    func invalidateResults() {
        analysis = nil
        messages = nil
        savedSessionID = nil
        didRequestRemoteAnalysis = false
        didRequestRemoteMessages = false
    }
}

/// 저장된 감정 세션을 기기 내에만 보관한다.
@MainActor
final class SessionStore: ObservableObject {
    static let shared = SessionStore()

    @Published private(set) var sessions: [EmotionSession] = []

    private let storageKey = "emotionbreaker.sessions"

    private init() {
        load()
    }

    func save(_ session: EmotionSession) {
        sessions.insert(session, at: 0)
        persist()
    }

    func delete(_ session: EmotionSession) {
        sessions.removeAll { $0.id == session.id }
        persist()
    }

    func session(with id: UUID) -> EmotionSession? {
        sessions.first { $0.id == id }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([EmotionSession].self, from: data)
        else { return }
        sessions = decoded
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(sessions) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
