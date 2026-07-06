import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var flow: FlowStore
    @ObservedObject private var store = SessionStore.shared
    @State private var sessionToDelete: EmotionSession?

    private var sessions: [EmotionSession] {
        store.sessions
    }

    var body: some View {
        Group {
            if sessions.isEmpty {
                emptyState
            } else {
                sessionList
            }
        }
        .background(Color.appBackground)
        .navigationTitle("기록")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "이 기록을 삭제할까요?",
            isPresented: Binding(
                get: { sessionToDelete != nil },
                set: { if !$0 { sessionToDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("삭제하기", role: .destructive) {
                if let session = sessionToDelete {
                    store.delete(session)
                }
                sessionToDelete = nil
            }
            Button("취소", role: .cancel) {
                sessionToDelete = nil
            }
        } message: {
            Text("삭제한 기록은 되돌릴 수 없어요.")
        }
    }

    private var emptyState: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                VStack(spacing: 12) {
                    Image("DuriCurious")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 110)
                        .accessibilityHidden(true)
                    Text("아직 저장된 기록이 없어요.")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color.appTextSecondary)
                    Text("세션 마지막 화면에서 저장을 선택하면 여기에 남아요.")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(Color.appTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(Color.appCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color.appBorder, style: StrokeStyle(lineWidth: 1, dash: [6]))
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(20)
        }
    }

    private var sessionList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                header
                ForEach(sessions) { session in
                    sessionCard(session)
                }
            }
            .padding(20)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("저장한 감정 세션")
                .font(.title.weight(.black))
                .foregroundStyle(Color.appTextPrimary)
            Text("기록은 이 기기에만 저장돼요. 언제든 삭제할 수 있어요.")
                .font(.footnote.weight(.medium))
                .foregroundStyle(Color.appTextSecondary)
        }
    }

    private func sessionCard(_ session: EmotionSession) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                flow.path.append(.historyDetail(session.id))
            } label: {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(session.selectedEmotion?.label ?? "감정 세션")
                            .font(.headline.weight(.black))
                            .foregroundStyle(Color.appTextPrimary)
                        Spacer()
                        if let before = session.emotionScoreBefore {
                            Text(scoreText(before: before, after: session.emotionScoreAfter))
                                .font(.footnote.weight(.bold))
                                .foregroundStyle(Color.appAccent)
                        }
                    }
                    Text(session.originalText)
                        .font(.body.weight(.medium))
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(2)
                    Text(session.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(session.selectedEmotion?.label ?? "감정 세션") 기록 상세 보기")

            Button {
                sessionToDelete = session
            } label: {
                Label("삭제", systemImage: "trash")
            }
            .buttonStyle(
                CompactActionButtonStyle(
                    foreground: .appWarnText,
                    background: .appWarnBackground
                )
            )
        }
        .card()
    }

    private func scoreText(before: Int, after: Int?) -> String {
        if let after {
            return "\(before)점 → \(after)점"
        }
        return "\(before)점"
    }
}

struct HistoryDetailView: View {
    @EnvironmentObject private var flow: FlowStore
    @ObservedObject private var store = SessionStore.shared
    let sessionID: UUID
    @State private var showDeleteConfirm = false

    private var session: EmotionSession? {
        store.session(with: sessionID)
    }

    var body: some View {
        Group {
            if let session {
                detail(for: session)
            } else {
                VStack(spacing: 12) {
                    Text("이 기록을 찾을 수 없어요.")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color.appTextSecondary)
                    Button("기록 목록으로") {
                        flow.path.removeLast()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .padding(.horizontal, 40)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color.appBackground)
        .navigationTitle("기록 상세")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detail(for session: EmotionSession) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(session.selectedEmotion?.label ?? "감정 세션")
                        .font(.title.weight(.black))
                        .foregroundStyle(Color.appTextPrimary)
                    Text(session.createdAt.formatted(date: .long, time: .shortened))
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(Color.appTextSecondary)
                    if let before = session.emotionScoreBefore {
                        Text(session.emotionScoreAfter.map { "감정 점수 \(before)점 → \($0)점" } ?? "감정 점수 \(before)점")
                            .font(.body.weight(.bold))
                            .foregroundStyle(Color.appAccent)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("털어놓은 말")
                        .font(.headline.weight(.black))
                        .foregroundStyle(Color.appTextPrimary)
                    Text(session.originalText)
                        .font(.body.weight(.medium))
                        .foregroundStyle(Color.appTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .card()

                if let analysis = session.analysis {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("마음 정리")
                            .font(.headline.weight(.black))
                            .foregroundStyle(Color.appTextPrimary)
                        detailRow("감정", ([analysis.primaryEmotion] + analysis.secondaryEmotions).joined(separator: ", "))
                        detailRow("사실", analysis.fact)
                        detailRow("내 해석", analysis.interpretation)
                        detailRow("진짜 욕구", analysis.desire)
                    }
                    .card()
                }

                if let messages = session.messages {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("추천 문장")
                            .font(.headline.weight(.black))
                            .foregroundStyle(Color.appTextPrimary)
                        ForEach(MessageTone.allCases) { tone in
                            detailRow(tone.label, messages.text(for: tone))
                        }
                    }
                    .card()
                }

                Button {
                    showDeleteConfirm = true
                } label: {
                    Label("이 기록 삭제하기", systemImage: "trash")
                        .font(.body.weight(.bold))
                        .foregroundStyle(Color.appWarnText)
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .background(Color.appWarnBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(20)
        }
        .confirmationDialog("이 기록을 삭제할까요?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("삭제하기", role: .destructive) {
                flow.sessionStore.delete(session)
                flow.path.removeLast()
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("삭제한 기록은 되돌릴 수 없어요.")
        }
    }

    private func detailRow(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.footnote.weight(.bold))
                .foregroundStyle(Color.appAccent)
            Text(body)
                .font(.body.weight(.medium))
                .foregroundStyle(Color.appTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 4)
    }
}
