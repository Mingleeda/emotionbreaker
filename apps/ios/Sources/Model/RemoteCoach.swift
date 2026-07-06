import Foundation

/// 서버(웹 앱 API Route)를 통해 AI 분석/문장 추천을 가져온다.
/// OpenRouter API 키는 서버에만 있고, 앱은 자체 서버만 호출한다.
/// 실패하면 nil을 반환하고 호출부는 LocalCoach 결과를 유지한다.
enum RemoteCoach {
    private static var baseURL: URL? {
        guard let string = Bundle.main.object(forInfoDictionaryKey: "EmotionCoachBaseURL") as? String,
              !string.isEmpty
        else { return nil }
        return URL(string: string)
    }

    private static let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        return URLSession(configuration: configuration)
    }()

    static func fetchAnalysis(
        originalText: String,
        selectedEmotion: SelectedEmotion?,
        emotionScoreBefore: Int?,
        emotionScoreAfter: Int?
    ) async -> EmotionAnalysisResult? {
        struct RequestBody: Encodable {
            let originalText: String
            let selectedEmotion: SelectedEmotion?
            let emotionScoreBefore: Int?
            let emotionScoreAfter: Int?
        }

        return await post(
            path: "api/analyze-emotion",
            body: RequestBody(
                originalText: originalText,
                selectedEmotion: selectedEmotion,
                emotionScoreBefore: emotionScoreBefore,
                emotionScoreAfter: emotionScoreAfter
            )
        )
    }

    static func fetchMessages(
        originalText: String,
        selectedEmotion: SelectedEmotion?,
        analysis: EmotionAnalysisResult?
    ) async -> SuggestedMessages? {
        struct RequestBody: Encodable {
            let originalMessage: String
            let selectedEmotion: SelectedEmotion?
            let analysis: EmotionAnalysisResult?
        }

        return await post(
            path: "api/rewrite-message",
            body: RequestBody(
                originalMessage: originalText,
                selectedEmotion: selectedEmotion,
                analysis: analysis
            )
        )
    }

    private static func post<Body: Encodable, Response: Decodable>(
        path: String,
        body: Body
    ) async -> Response? {
        guard let baseURL,
              let url = URL(string: path, relativeTo: baseURL),
              let payload = try? JSONEncoder().encode(body)
        else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = payload

        guard let (data, response) = try? await session.data(for: request),
              let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200
        else { return nil }

        return try? JSONDecoder().decode(Response.self, from: data)
    }
}
