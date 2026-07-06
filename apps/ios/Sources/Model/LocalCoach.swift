import Foundation

/// 온디바이스 감정 코치 로직. 웹 MVP의 lib/session/flow-store.ts, lib/safety/risk-detection.ts 포팅.
/// API 키 없이도 동작하도록 로컬 휴리스틱으로 분석/문장 추천을 생성한다.
enum LocalCoach {

    // MARK: - 위험 감지

    private static let crisisPatterns = [
        "죽고 싶어",
        "사라지고 싶어",
        "나를 해치고 싶어",
        "끝내고 싶어",
        "죽여버리고 싶어",
        "때리고 싶어",
        "가서 해치고 싶어",
        "지금 뛰어내릴 거야",
        "칼을 들고 있어",
        "지금 찾아갈 거야",
    ]

    static func detectRiskLevel(in text: String) -> RiskLevel {
        let normalized = normalize(text)
        if crisisPatterns.contains(where: { normalized.contains($0) }) {
            return .crisis
        }
        return .normal
    }

    // MARK: - 분석 생성

    static func makeAnalysis(
        selectedEmotion: SelectedEmotion?,
        originalText: String
    ) -> EmotionAnalysisResult {
        let emotion = selectedEmotion ?? .anger
        return EmotionAnalysisResult(
            riskLevel: detectRiskLevel(in: originalText),
            primaryEmotion: emotion.analysisLabel,
            secondaryEmotions: ["긴장", "답답함"],
            fact: situationPhrase(from: originalText),
            interpretation: "상대가 내 마음이나 입장을 충분히 알아주지 않는다고 느낀 것 같아요.",
            desire: "내 말을 끝까지 듣고, 내 입장을 존중해주길 바라는 마음이 있어 보여요.",
            notRecommendedAction: "감정이 가장 높은 상태에서 바로 따지듯 메시지를 보내기.",
            recommendedAction: "한 문장으로 내 감정과 요청을 분리해서 전달하기.",
            situationSummary: "감정이 올라온 상황에서 바로 반응하기 전 잠시 멈추고 정리하려는 상태."
        )
    }

    // MARK: - 관계 추론

    private enum Relationship {
        case work, family, partner, friend, general
    }

    private static func inferRelationship(from text: String) -> Relationship {
        let workWords = ["상사", "파트장", "팀장", "부장", "회사", "회의", "업무", "직장", "동료", "고객", "클라이언트", "출장", "출근"]
        let familyWords = ["엄마", "아빠", "부모", "가족", "형", "누나", "언니", "오빠", "동생"]
        let partnerWords = ["남자친구", "여자친구", "연인", "애인", "남친", "여친", "배우자", "남편", "아내"]
        let friendWords = ["친구", "지인", "선배", "후배"]

        if workWords.contains(where: { text.contains($0) }) { return .work }
        if familyWords.contains(where: { text.contains($0) }) { return .family }
        if partnerWords.contains(where: { text.contains($0) }) { return .partner }
        if friendWords.contains(where: { text.contains($0) }) { return .friend }
        return .general
    }

    // MARK: - 상황 요약

    static func situationPhrase(from rawText: String) -> String {
        let text = normalize(rawText)
        let cleaned = cleanSituationPhrase(text)
        if cleaned.isEmpty {
            return "방금 있었던 일"
        }
        if cleaned.count > 70 {
            return String(cleaned.prefix(70)) + "..."
        }
        return cleaned
    }

    private static func cleanSituationPhrase(_ normalized: String) -> String {
        if normalized.isEmpty { return "" }

        let workContext = ["팀장", "상사", "파트장", "부장", "회사", "업무", "직장", "동료"]
        let orderWords = ["통보", "요구", "지시", "받았"]

        if matches(normalized, pattern: "(하\\s*고\\s*싶지\\s*않은\\s*일|하고싶지\\s*않은\\s*일|원치\\s*않는\\s*(일|업무|일정)|원하지\\s*않는\\s*(일|업무|일정)|하기\\s*싫은\\s*(일|업무|일정))") {
            if workContext.contains(where: { normalized.contains($0) }),
               orderWords.contains(where: { normalized.contains($0) }) {
                return "원치 않는 업무를 충분한 논의 없이 통보받은 일"
            }
            return "원치 않는 일을 맡게 된 상황"
        }

        if matches(normalized, pattern: "(말을|말|의견).{0,12}(끊|자르)") {
            return normalized.contains("회의")
                ? "회의 중 제 말을 끝까지 듣지 않은 일"
                : "제 말을 끝까지 듣지 않은 일"
        }

        if matches(normalized, pattern: "(출장|출근|셔틀|이천)") {
            let place: String
            if let match = firstMatch(normalized, pattern: "([가-힣A-Za-z0-9]+)\\s*출장") {
                place = "\(match) 출장"
            } else {
                place = "출장"
            }

            let sudden = matches(normalized, pattern: "(갑자기|갑작|갑작스러운|통보|요구)")
            if sudden, matches(normalized, pattern: "(아침|오전|새벽|6시|7시|8시|셔틀|출근)") {
                return "갑작스러운 \(place)과 이른 출근 일정 통보"
            }
            if sudden {
                return "갑작스러운 \(place) 요청"
            }
            return "\(place) 일정"
        }

        if normalized.contains("무시") || normalized.contains("존중") {
            return "제가 존중받지 못한다고 느낀 일"
        }

        if workContext.contains(where: { normalized.contains($0) }),
           ["통보", "요구", "지시"].contains(where: { normalized.contains($0) }) {
            return "업무 내용을 충분한 논의 없이 통보받은 일"
        }

        if matches(normalized, pattern: "(약속|늦|기다)") {
            return "약속이나 기다림과 관련해 마음이 상한 일"
        }

        let firstSentence = normalized
            .components(separatedBy: CharacterSet(charactersIn: ".!?。！？"))
            .first ?? normalized

        var result = firstSentence
        result = replacing(result, pattern: "너무\\s*(화가|짜증이|속상|서운).*", with: "")
        result = replacing(result, pattern: "바로\\s*(따지고|말하고|보내고).*", with: "")
        result = replacing(result, pattern: "(화가 나|짜증나|빡쳐|열받아|억울해|서운해).*", with: "")
        result = replacing(result, pattern: "\\s*(때문에|라서|해서|어서|니까)\\s*$", with: "")
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - 문장 추천

    static func makeSuggestedMessages(
        originalText: String,
        analysis: EmotionAnalysisResult?
    ) -> SuggestedMessages {
        let source = normalize(originalText)
        let relationship = inferRelationship(from: source)
        let situation = analysis.map { normalize($0.fact) }.flatMap { $0.isEmpty ? nil : $0 }
            ?? situationPhrase(from: source)
        let topic = withTopicParticle(situation)
        let desire = desirePhrase(analysis: analysis)

        switch relationship {
        case .work:
            if let messages = workMessages(for: situation) {
                return messages
            }
            let opening = workOpening(for: situation)
            return SuggestedMessages(
                soft: "\(opening) 많이 당황했습니다. 일정 조율이 필요한 부분이라 제 상황도 함께 봐주시면 좋겠습니다.",
                firm: "\(topic) 제게 부담이 큰 일정입니다. 가능한 범위와 조정 방법을 다시 논의하고 싶습니다.",
                short: "\(situation) 관련해서 제 상황도 함께 말씀드리고 싶습니다."
            )
        case .family:
            return SuggestedMessages(
                soft: "\(situation) 때문에 마음이 많이 상했어요. 싸우고 싶다기보다, \(desire)이 있다는 걸 알아줬으면 해요.",
                firm: "\(topic) 저에게 가볍게 느껴지지 않았어요. 같은 일이 반복되지 않도록 제 이야기도 끝까지 들어주세요.",
                short: "\(situation) 때문에 마음이 상했어요. 제 이야기도 들어줬으면 해요."
            )
        case .partner:
            return SuggestedMessages(
                soft: "\(situation) 때문에 서운하고 속상했어요. 비난하려는 건 아니고, \(desire)이 있다는 걸 말하고 싶어요.",
                firm: "\(topic) 저에게 중요한 문제예요. 감정적으로 싸우기보다 서로 어떻게 느꼈는지 차분히 이야기하고 싶어요.",
                short: "\(situation) 때문에 서운했어요. 차분히 이야기하고 싶어요."
            )
        case .friend:
            return SuggestedMessages(
                soft: "\(situation) 때문에 마음이 좀 불편했어. 따지려는 건 아니고, 내 입장도 한 번 말하고 싶어.",
                firm: "\(topic) 나한테 그냥 넘기기 어려웠어. 다음에는 내 이야기도 조금 더 들어줬으면 해.",
                short: "\(situation) 때문에 불편했어. 내 입장도 말하고 싶어."
            )
        case .general:
            return SuggestedMessages(
                soft: "\(situation) 때문에 감정이 많이 올라왔어요. 바로 따지기보다, \(desire)이 있다는 걸 차분히 전하고 싶습니다.",
                firm: "\(topic) 제게 중요한 부분입니다. 감정적으로 반응하기보다 제 입장을 분명히 설명하고 싶습니다.",
                short: "\(situation) 때문에 마음이 불편했습니다. 제 입장도 말하고 싶습니다."
            )
        }
    }

    private static func workMessages(for situation: String) -> SuggestedMessages? {
        if situation.contains("원치 않는 업무") {
            return SuggestedMessages(
                soft: "말씀하신 업무가 제 상황에서는 바로 받아들이기 어려워 당황했습니다. 맡아야 하는 범위와 조정 가능한 부분을 함께 다시 확인하고 싶습니다.",
                firm: "그 업무는 현재 제 상황에서 부담이 큽니다. 바로 진행하기보다 필요성, 범위, 일정 조정 가능 여부를 먼저 논의하고 싶습니다.",
                short: "그 업무는 지금 바로 맡기 어렵습니다. 범위와 일정 조정을 먼저 논의하고 싶습니다."
            )
        }
        if situation.contains("충분한 논의 없이 통보") {
            return SuggestedMessages(
                soft: "업무 내용이 충분한 논의 없이 전달되어 많이 당황했습니다. 제 상황도 함께 고려해서 조정할 수 있을지 이야기 나누고 싶습니다.",
                firm: "이번 건은 제게 부담이 큰 결정입니다. 일방적으로 진행하기보다 범위와 조정 방법을 다시 논의하고 싶습니다.",
                short: "이번 건은 제 상황도 함께 봐야 할 것 같습니다. 조정 가능 여부를 논의하고 싶습니다."
            )
        }
        return nil
    }

    private static func workOpening(for situation: String) -> String {
        if situation.contains("원치 않는 업무") {
            return "말씀하신 업무가 제 상황에서는 바로 받아들이기 어려워"
        }
        if situation.contains("충분한 논의 없이 통보") {
            return "업무 내용을 충분히 논의하지 못한 채 전달받아"
        }
        if situation.hasSuffix("통보") { return "\(situation)를 받고" }
        if situation.hasSuffix("요청") { return "\(situation)을 받고" }
        if situation.hasSuffix("일정") { return "\(situation)을 듣고" }
        return "\(situation) 때문에"
    }

    private static func desirePhrase(analysis: EmotionAnalysisResult?) -> String {
        let raw = normalize(analysis?.desire ?? "")
        if raw.isEmpty {
            return "제 입장도 차분히 들어주셨으면 하는 마음"
        }
        var result = replacing(raw, pattern: " 있어 보여요\\.?$", with: "")
        result = replacing(result, pattern: " 마음이$", with: "")
        return result
    }

    // MARK: - 도움 자료

    static func resources(for type: ResourceType) -> [ResourceRecommendation] {
        switch type {
        case .video:
            return [
                ResourceRecommendation(
                    id: "video-1",
                    title: "화가 올라올 때 멈추는 3분 호흡",
                    type: .video,
                    durationMinutes: 3,
                    description: "감정 강도가 높을 때 몸의 긴장을 먼저 낮추는 짧은 영상입니다.",
                    reason: "지금은 긴 설명보다 짧게 따라 할 수 있는 자료가 좋아요."
                ),
            ]
        case .meditation:
            return [
                ResourceRecommendation(
                    id: "meditation-1",
                    title: "4초 들숨, 6초 날숨 루틴",
                    type: .meditation,
                    durationMinutes: 5,
                    description: "호흡을 천천히 맞추며 즉각적인 반응을 늦추는 연습입니다.",
                    reason: "감정이 빠르게 올라올 때 호흡 속도를 낮추는 데 도움이 됩니다."
                ),
            ]
        case .book:
            return [
                ResourceRecommendation(
                    id: "book-1",
                    title: "비폭력 대화 연습",
                    type: .book,
                    durationMinutes: nil,
                    description: "사실, 감정, 욕구, 부탁을 분리해 말하는 연습에 도움이 되는 책입니다.",
                    reason: "상대에게 보낼 말을 차분한 요청으로 바꾸는 데 맞는 자료입니다."
                ),
            ]
        }
    }

    // MARK: - 유틸

    private static func normalize(_ text: String) -> String {
        text.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func matches(_ text: String, pattern: String) -> Bool {
        text.range(of: pattern, options: .regularExpression) != nil
    }

    private static func firstMatch(_ text: String, pattern: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              match.numberOfRanges > 1,
              let range = Range(match.range(at: 1), in: text)
        else { return nil }
        return String(text[range])
    }

    private static func replacing(_ text: String, pattern: String, with replacement: String) -> String {
        text.replacingOccurrences(of: pattern, with: replacement, options: .regularExpression)
    }

    private static func withTopicParticle(_ text: String) -> String {
        guard let lastScalar = text.unicodeScalars.last else { return text }
        let code = Int(lastScalar.value)
        guard code >= 0xAC00, code <= 0xD7A3 else { return "\(text)는" }
        let hasBatchim = (code - 0xAC00) % 28 != 0
        return "\(text)\(hasBatchim ? "은" : "는")"
    }
}
