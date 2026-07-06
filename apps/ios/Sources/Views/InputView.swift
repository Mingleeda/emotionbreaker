import SwiftUI

struct InputView: View {
    @EnvironmentObject private var flow: FlowStore
    @State private var text: String = ""
    @FocusState private var isEditorFocused: Bool

    private var trimmedText: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 10) {
                    StepBadge(symbol: "text.bubble", text: "1단계 · 털어놓기")
                    Text("있는 그대로 적어주세요.")
                        .font(.title.weight(.black))
                        .foregroundStyle(Color.appTextPrimary)
                    Text("욕처럼 나와도 괜찮아요. 보내기 전에 차분한 말로 바꿔볼게요.")
                        .font(.body.weight(.medium))
                        .foregroundStyle(Color.appTextSecondary)
                }

                TextEditor(text: $text)
                    .focused($isEditorFocused)
                    .font(.title3.weight(.medium))
                    .scrollContentBackground(.hidden)
                    .padding(14)
                    .frame(minHeight: 240)
                    .background(Color.appCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(isEditorFocused ? Color.appPrimary : Color.appBorder, lineWidth: 2)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(alignment: .topLeading) {
                        if text.isEmpty {
                            Text("예: 상사가 회의 중에 내 말을 끊어서 너무 화가 나. 바로 따지고 싶어.")
                                .font(.title3.weight(.medium))
                                .foregroundStyle(Color.appTextSecondary.opacity(0.6))
                                .padding(.horizontal, 19)
                                .padding(.vertical, 22)
                                .allowsHitTesting(false)
                        }
                    }
                    .accessibilityLabel("지금 상황과 감정을 적는 곳")
            }
            .padding(20)
        }
        .background(Color.appBackground)
        .navigationTitle("털어놓기")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom) {
            Button {
                flow.inputType = .text
                flow.originalText = trimmedText
                flow.invalidateResults()
                isEditorFocused = false
                flow.path.append(.intensity)
            } label: {
                Label("감정 점수 고르기", systemImage: "arrow.right")
            }
            .buttonStyle(PrimaryButtonStyle(isEnabled: !trimmedText.isEmpty))
            .disabled(trimmedText.isEmpty)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.bar)
        }
        .onAppear {
            if text.isEmpty {
                text = flow.originalText
            }
        }
    }
}
