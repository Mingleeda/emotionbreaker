import SwiftUI

struct AnalysisView: View {
    @EnvironmentObject private var flow: FlowStore

    private var scoreSummary: String? {
        guard let before = flow.emotionScoreBefore, let after = flow.emotionScoreAfter else {
            return nil
        }
        return "\(before)점에서 \(after)점으로 확인했어요."
    }

    var body: some View {
        Group {
            if flow.analysis?.riskLevel == .crisis {
                CrisisView()
            } else {
                analysisContent
            }
        }
        .background(Color.appBackground)
        .navigationTitle("마음 정리")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            flow.prepareAnalysis()
        }
    }

    @ViewBuilder
    private var analysisContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 10) {
                    StepBadge(symbol: "brain.head.profile", text: "5단계 · 마음 정리")
                    Text("바로 보내기 전에, 이렇게 나눠볼게요.")
                        .font(.title.weight(.black))
                        .foregroundStyle(Color.appTextPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    if let scoreSummary {
                        Text(scoreSummary)
                            .font(.body.weight(.medium))
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }

                if let analysis = flow.analysis {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("먼저 할 일")
                            .font(.title3.weight(.black))
                            .foregroundStyle(.white)
                        Text(analysis.recommendedAction)
                            .font(.body.weight(.medium))
                            .foregroundStyle(.white.opacity(0.92))
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.appPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    ForEach(sections(for: analysis), id: \.title) { section in
                        VStack(alignment: .leading, spacing: 10) {
                            Label(section.title, systemImage: section.symbol)
                                .font(.headline.weight(.black))
                                .foregroundStyle(Color.appTextPrimary)
                            Text(section.body)
                                .font(.body.weight(.medium))
                                .foregroundStyle(Color.appTextSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .card()
                    }
                }
            }
            .padding(20)
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 10) {
                Button {
                    flow.path.append(.rewrite)
                } label: {
                    Label("보낼 말 추천받기", systemImage: "arrow.right")
                }
                .buttonStyle(PrimaryButtonStyle())

                Button {
                    flow.path.append(.resources)
                } label: {
                    Text("도움 자료 보기")
                }
                .buttonStyle(LowPriorityButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.bar)
        }
    }

    private func sections(for analysis: EmotionAnalysisResult) -> [(title: String, symbol: String, body: String)] {
        [
            ("감정", "heart", ([analysis.primaryEmotion] + analysis.secondaryEmotions).joined(separator: ", ")),
            ("사실", "checklist", analysis.fact),
            ("내 해석", "brain", analysis.interpretation),
            ("진짜 욕구", "target", analysis.desire),
            ("지금 하지 않을 것", "nosign", analysis.notRecommendedAction),
            ("지금 할 수 있는 것", "bubble.left", analysis.recommendedAction),
        ]
    }
}

/// 위험 표현 감지 시 일반 코칭을 중단하고 도움 안내로 전환한다.
struct CrisisView: View {
    @EnvironmentObject private var flow: FlowStore
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("도움이 먼저 필요해요")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.appAccent)
                    Text("지금은 혼자 버티지 않는 게 중요해요.")
                        .font(.title.weight(.black))
                        .foregroundStyle(Color.appTextPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Text("지금은 혼자 버티기보다 즉시 도움을 받는 게 중요해 보여요. 가까운 사람에게 바로 연락하거나, 아래 번호로 연락해 주세요.")
                    .font(.body.weight(.medium))
                    .foregroundStyle(Color.appWarnText)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.appWarnBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                Button {
                    openURL(URL(string: "tel:109")!)
                } label: {
                    Label("자살예방 상담전화 109", systemImage: "phone.fill")
                }
                .buttonStyle(PrimaryButtonStyle())

                Button {
                    openURL(URL(string: "tel:112")!)
                } label: {
                    Label("긴급 상황 112 / 119", systemImage: "light.beacon.max")
                }
                .buttonStyle(SecondaryButtonStyle())

                Button {
                    flow.finishFlow()
                } label: {
                    Text("처음으로 돌아가기")
                }
                .buttonStyle(LowPriorityButtonStyle())
            }
            .padding(20)
        }
    }
}
