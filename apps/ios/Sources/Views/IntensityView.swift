import SwiftUI

struct IntensityView: View {
    @EnvironmentObject private var flow: FlowStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    StepBadge(symbol: "waveform.path.ecg", text: "2단계 · 감정 세기")
                    Text("지금 몇 점인가요?")
                        .font(.title.weight(.black))
                        .foregroundStyle(Color.appTextPrimary)
                    Text("생각하지 말고, 몸으로 느껴지는 숫자를 눌러주세요.")
                        .font(.body.weight(.medium))
                        .foregroundStyle(Color.appTextSecondary)
                }

                ScoreGrid { score in
                    flow.selectScoreBefore(score)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Label("4점 이상이면 먼저 60초만 멈춥니다.", systemImage: "exclamationmark.triangle")
                        .font(.body.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text("0 = 괜찮음 · 10 = 바로 폭발할 것 같음")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(Color.appTextSecondary)
                }
                .card()
            }
            .padding(20)
        }
        .background(Color.appBackground)
        .navigationTitle("감정 세기")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ReassessView: View {
    @EnvironmentObject private var flow: FlowStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    StepBadge(symbol: "arrow.counterclockwise", text: "4단계 · 다시 확인")
                    Text("조금 내려왔나요?")
                        .font(.title.weight(.black))
                        .foregroundStyle(Color.appTextPrimary)
                    Text("처음 감정 점수는 \(flow.emotionScoreBefore.map(String.init) ?? "-")점이었어요. 지금은 몇 점인가요?")
                        .font(.body.weight(.medium))
                        .foregroundStyle(Color.appTextSecondary)
                }

                ScoreGrid { score in
                    flow.selectScoreAfter(score)
                }
            }
            .padding(20)
        }
        .background(Color.appBackground)
        .navigationTitle("다시 확인")
        .navigationBarTitleDisplayMode(.inline)
    }
}
