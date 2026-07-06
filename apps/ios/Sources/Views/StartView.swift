import SwiftUI

struct StartView: View {
    @EnvironmentObject private var flow: FlowStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let emotion = flow.selectedEmotion {
                    selectedContent(for: emotion)
                } else {
                    pickerContent
                }
            }
            .padding(20)
        }
        .background(Color.appBackground)
        .navigationTitle("시작하기")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func selectedContent(for emotion: SelectedEmotion) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("지금 상태")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color.appAccent)
            Text(emotion.label)
                .font(.largeTitle.weight(.black))
                .foregroundStyle(Color.appTextPrimary)
            Text("어떻게 털어놓을까요? 말로 해도 되고, 글로 적어도 괜찮아요.")
                .font(.body.weight(.medium))
                .foregroundStyle(Color.appTextSecondary)
        }
        .card()

        Button {
            flow.path.append(.voice)
        } label: {
            Label("말로 털어놓기", systemImage: "mic.fill")
        }
        .buttonStyle(PrimaryButtonStyle())

        Button {
            flow.path.append(.input)
        } label: {
            Label("글로 적기", systemImage: "keyboard")
        }
        .buttonStyle(SecondaryButtonStyle())

        Button {
            flow.selectedEmotion = nil
        } label: {
            Label("감정 다시 고르기", systemImage: "arrow.counterclockwise")
        }
        .buttonStyle(LowPriorityButtonStyle())
    }

    @ViewBuilder
    private var pickerContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("지금 마음에 가까운 걸 골라주세요.")
                .font(.title.weight(.black))
                .foregroundStyle(Color.appTextPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Text("고른 다음, 말로 할지 글로 쓸지 선택할 수 있어요.")
                .font(.body.weight(.medium))
                .foregroundStyle(Color.appTextSecondary)
        }

        VStack(spacing: 10) {
            ForEach(SelectedEmotion.allCases, id: \.self) { emotion in
                Button {
                    flow.selectedEmotion = emotion
                } label: {
                    Text(emotion.label)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                        .frame(maxWidth: .infinity, minHeight: 60, alignment: .leading)
                        .padding(.horizontal, 16)
                        .background(Color.appCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(Color.appBorder, lineWidth: 2)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
        }
    }
}
