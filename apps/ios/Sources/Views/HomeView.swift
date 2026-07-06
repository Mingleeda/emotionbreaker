import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var flow: FlowStore

    private let quickEmotions: [(label: String, value: SelectedEmotion)] = [
        ("화가 나요", .anger),
        ("불안해요", .anxiety),
        ("서운해요", .hurt),
        ("억울해요", .injustice),
        ("잠깐 멈추고 싶어요", .pause),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                hero

                VStack(spacing: 12) {
                    Button {
                        flow.invalidateResults()
                        flow.path.append(.voice)
                    } label: {
                        Label("말로 털어놓기", systemImage: "mic.fill")
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    Button {
                        flow.invalidateResults()
                        flow.path.append(.input)
                    } label: {
                        Label("글로 적기", systemImage: "keyboard")
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }

                VStack(alignment: .leading, spacing: 12) {
                    Label("지금 상태에 가까운 것", systemImage: "pause.circle")
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)

                    VStack(spacing: 10) {
                        ForEach(quickEmotions, id: \.label) { emotion in
                            Button {
                                flow.invalidateResults()
                                flow.selectedEmotion = emotion.value
                                flow.path.append(.start)
                            } label: {
                                Text(emotion.label)
                                    .font(.body.weight(.bold))
                                    .foregroundStyle(Color.appTextPrimary)
                                    .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
                                    .padding(.horizontal, 16)
                                    .background(Color.appCard)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .strokeBorder(Color.appBorder, lineWidth: 1)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(Color.appBackground)
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    flow.path.append(.history)
                } label: {
                    Label("기록", systemImage: "clock.arrow.circlepath")
                }
                .accessibilityLabel("저장한 기록 보기")
            }
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 14) {
                    Label("보내기 전 60초", systemImage: "timer")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.appAccent)

                    Text("보내기 전에\n60초만 멈춰요.")
                        .font(.largeTitle.weight(.black))
                        .foregroundStyle(Color.appTextPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 4)

                Image("DuriWelcome")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 136)
                    .accessibilityHidden(true)
            }

            Text("화가 치밀거나 말이 세게 나올 것 같을 때, 먼저 멈추고 차분한 문장으로 바꿔볼게요.")
                .font(.body.weight(.medium))
                .foregroundStyle(Color.appTextSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Label("상담이나 진단이 아니라, 지금 반응을 늦추는 도구예요.", systemImage: "checkmark.shield")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.appTextSecondary)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.appMint)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .card()
    }
}
