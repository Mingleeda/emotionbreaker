import Foundation

enum InputType: String, Codable {
    case text
    case voice
}

enum SelectedEmotion: String, Codable, CaseIterable {
    case anger
    case anxiety
    case hurt
    case injustice
    case pause

    var label: String {
        switch self {
        case .anger: return "화가 나요"
        case .anxiety: return "불안해요"
        case .hurt: return "서운해요"
        case .injustice: return "억울해요"
        case .pause: return "잠깐 멈추고 싶어요"
        }
    }

    var analysisLabel: String {
        switch self {
        case .anger: return "화남"
        case .anxiety: return "불안"
        case .hurt: return "서운함"
        case .injustice: return "억울함"
        case .pause: return "정리하고 싶은 마음"
        }
    }
}

enum RiskLevel: String, Codable {
    case normal
    case caution
    case crisis
}

struct EmotionAnalysisResult: Codable, Equatable {
    var riskLevel: RiskLevel
    var primaryEmotion: String
    var secondaryEmotions: [String]
    var fact: String
    var interpretation: String
    var desire: String
    var notRecommendedAction: String
    var recommendedAction: String
    var situationSummary: String
}

enum MessageTone: String, Codable, CaseIterable, Identifiable {
    case soft
    case firm
    case short

    var id: String { rawValue }

    var label: String {
        switch self {
        case .soft: return "부드럽게"
        case .firm: return "단호하게"
        case .short: return "짧게"
        }
    }
}

struct SuggestedMessages: Codable, Equatable {
    var soft: String
    var firm: String
    var short: String

    func text(for tone: MessageTone) -> String {
        switch tone {
        case .soft: return soft
        case .firm: return firm
        case .short: return short
        }
    }
}

enum ResourceType: String, Codable, CaseIterable, Identifiable {
    case video
    case meditation
    case book

    var id: String { rawValue }

    var label: String {
        switch self {
        case .video: return "짧은 영상"
        case .meditation: return "호흡/명상"
        case .book: return "책 추천"
        }
    }

    var symbol: String {
        switch self {
        case .video: return "play.rectangle"
        case .meditation: return "wind"
        case .book: return "book"
        }
    }
}

struct ResourceRecommendation: Codable, Identifiable, Equatable {
    var id: String
    var title: String
    var type: ResourceType
    var durationMinutes: Int?
    var description: String?
    var reason: String?
}

struct EmotionSession: Codable, Identifiable, Equatable {
    var id: UUID
    var createdAt: Date
    var selectedEmotion: SelectedEmotion?
    var inputType: InputType?
    var originalText: String
    var emotionScoreBefore: Int?
    var emotionScoreAfter: Int?
    var analysis: EmotionAnalysisResult?
    var messages: SuggestedMessages?
}
