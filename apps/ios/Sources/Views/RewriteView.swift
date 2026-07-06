import SwiftUI

struct RewriteView: View {
    @EnvironmentObject private var flow: FlowStore
    @State private var copiedTone: MessageTone?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 10) {
                    StepBadge(symbol: "bubble.left.and.text.bubble.right", text: "6단계 · 보낼 말")
                    Text("세게 나가지 않고, 분명하게 말해요.")
                        .font(.title.weight(.black))
                        .foregroundStyle(Color.appTextPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("방금 적은 상황을 반영해서 상대에게 보낼 말로 바꿨어요.")
                        .font(.body.weight(.medium))
                        .foregroundStyle(Color.appTextSecondary)
                }

                situationCard

                if let messages = flow.messages {
                    ForEach(MessageTone.allCases) { tone in
                        messageCard(tone: tone, text: messages.text(for: tone))
                    }
                }

                saveSection
            }
            .padding(20)
        }
        .background(Color.appBackground)
        .navigationTitle("보낼 말")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 10) {
                Button {
                    flow.path.append(.resources)
                } label: {
                    Label("도움 자료는 원할 때만 보기", systemImage: "play.rectangle")
                }
                .buttonStyle(SecondaryButtonStyle())

                Button {
                    flow.finishFlow()
                } label: {
                    Text("여기서 마치기")
                }
                .buttonStyle(LowPriorityButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.bar)
        }
        .onAppear {
            flow.prepareAnalysis()
            flow.prepareMessages()
        }
    }

    @ViewBuilder
    private var situationCard: some View {
        let situation = flow.analysis?.fact ?? LocalCoach.situationPhrase(from: flow.originalText)
        if !situation.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Label("반영한 상황", systemImage: "quote.opening")
                    .font(.footnote.weight(.black))
                    .foregroundStyle(Color.appTextPrimary)
                Text(situation)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .card()
        }
    }

    private func messageCard(tone: MessageTone, text: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(tone.label)
                .font(.title3.weight(.black))
                .foregroundStyle(Color.appTextPrimary)
            Text(text)
                .font(.body.weight(.medium))
                .foregroundStyle(Color.appTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .textSelection(.enabled)
            Button {
                UIPasteboard.general.string = text
                copiedTone = tone
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            } label: {
                Label(
                    copiedTone == tone ? "복사됨" : "복사하기",
                    systemImage: copiedTone == tone ? "checkmark" : "doc.on.doc"
                )
            }
            .buttonStyle(CompactActionButtonStyle())
            .accessibilityLabel("\(tone.label) 문장 복사하기")
        }
        .card()
    }

    @ViewBuilder
    private var saveSection: some View {
        if flow.savedSessionID != nil {
            HStack(spacing: 10) {
                Image("DuriCherish")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 56)
                    .accessibilityHidden(true)
                Text("이 세션을 저장했어요. 기록에서 다시 볼 수 있어요.")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                Button("기록 보기") {
                    flow.path.append(.history)
                }
                .font(.body.weight(.bold))
                .foregroundStyle(Color.appAccent)
            }
            .padding(16)
            .background(Color.appMint)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        } else {
            VStack(alignment: .leading, spacing: 10) {
                Text("이 세션을 남겨둘까요?")
                    .font(.headline.weight(.black))
                    .foregroundStyle(Color.appTextPrimary)
                Text("저장은 선택이에요. 저장하지 않으면 이 기록은 사라져요.")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Color.appTextSecondary)
                Button {
                    flow.saveCurrentSession()
                } label: {
                    Label("이 세션 저장하기", systemImage: "tray.and.arrow.down")
                }
                .buttonStyle(CompactActionButtonStyle())
            }
            .card()
        }
    }
}
