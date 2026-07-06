import SwiftUI

struct BreakView: View {
    @EnvironmentObject private var flow: FlowStore
    @Environment(\.scenePhase) private var scenePhase
    @ScaledMetric(relativeTo: .largeTitle) private var timerFontSize = 72

    @State private var remainingSeconds = 60
    @State private var running = false
    @State private var finished = false
    @State private var endDate: Date?

    private let steps: [(symbol: String, text: String)] = [
        ("shoeprints.fill", "발바닥이 바닥에 닿는 느낌을 느껴보세요."),
        ("figure.mind.and.body", "어깨 힘을 한 번 빼주세요."),
        ("wind", "코로 4초 들이마시고, 입으로 6초 내쉬어보세요."),
        ("checkmark.circle", "지금 당장 반응하지 않아도 괜찮다고 말해보세요."),
    ]

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 10) {
                    StepBadge(symbol: "pause.circle", text: "3단계 · 멈춤")
                    Text("지금은 답장 금지.")
                        .font(.title.weight(.black))
                        .foregroundStyle(Color.appTextPrimary)
                    Text("60초만 몸을 먼저 낮춰요. 판단은 그 다음입니다.")
                        .font(.body.weight(.medium))
                        .foregroundStyle(Color.appTextSecondary)
                }

                timerCard

                VStack(spacing: 10) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: step.symbol)
                                .font(.body.weight(.bold))
                                .foregroundStyle(Color.appAccent)
                                .frame(width: 36, height: 36)
                                .background(Color.appWarnBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            Text("\(index + 1)  \(step.text)")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(Color.appTextPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(14)
                        .background(Color.appCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(Color.appBorder, lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
            .padding(20)
        }
        .background(Color.appBackground)
        .navigationTitle("멈춤")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            bottomBar
        }
        .onReceive(timer) { _ in
            tick()
        }
        .onChange(of: scenePhase) { _, newPhase in
            // 백그라운드에 다녀와도 남은 시간이 실제 경과 기준으로 유지되도록 종료 시각으로 계산한다.
            if newPhase == .active {
                syncWithEndDate()
            }
        }
    }

    private var timerCard: some View {
        VStack(spacing: 6) {
            Image("DuriBreathe")
                .resizable()
                .scaledToFit()
                .frame(height: 104)
                .padding(.bottom, 4)
                .accessibilityHidden(true)
            Text(finished ? "60초 완료" : "남은 시간")
                .font(.footnote.weight(.bold))
                .foregroundStyle(Color.appTextSecondary)
            Text("\(remainingSeconds)")
                .font(.system(size: timerFontSize, weight: .black))
                .monospacedDigit()
                .foregroundStyle(Color.appTextPrimary)
                .contentTransition(.numericText(countsDown: true))
            Text(statusText)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(finished ? Color.appAccent : Color.appTextSecondary)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color.appCard)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(finished ? Color.appAccent.opacity(0.6) : Color.appBorder, lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(finished ? "60초 완료" : "남은 시간 \(remainingSeconds)초")
    }

    private var statusText: String {
        if finished { return "잘 멈췄어요. 이제 점수를 다시 확인해볼까요?" }
        if running { return "천천히. 지금은 멈추는 중이에요." }
        return "시작 버튼을 누르면 타이머가 내려갑니다."
    }

    @ViewBuilder
    private var bottomBar: some View {
        VStack(spacing: 10) {
            if finished {
                Button {
                    flow.path.append(.reassess)
                } label: {
                    Label("점수 다시 확인하기", systemImage: "arrow.right")
                }
                .buttonStyle(PrimaryButtonStyle())
            } else if running {
                Button {
                    flow.path.append(.reassess)
                } label: {
                    Text("다 했어요")
                }
                .buttonStyle(SecondaryButtonStyle())
            } else {
                Button {
                    startTimer()
                } label: {
                    Label("60초 시작", systemImage: "play.fill")
                }
                .buttonStyle(PrimaryButtonStyle())

                Button {
                    flow.path.append(.reassess)
                } label: {
                    Text("건너뛰고 점수 확인하기")
                }
                .buttonStyle(LowPriorityButtonStyle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.bar)
    }

    private func startTimer() {
        remainingSeconds = 60
        endDate = Date().addingTimeInterval(60)
        running = true
        finished = false
    }

    private func tick() {
        guard running else { return }
        syncWithEndDate()
    }

    private func syncWithEndDate() {
        guard running, let endDate else { return }
        let remaining = max(0, Int(endDate.timeIntervalSinceNow.rounded()))
        withAnimation {
            remainingSeconds = remaining
        }
        if remaining <= 0 {
            running = false
            finished = true
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
}
