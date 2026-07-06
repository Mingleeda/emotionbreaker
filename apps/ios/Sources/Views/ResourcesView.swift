import SwiftUI

struct ResourcesView: View {
    @EnvironmentObject private var flow: FlowStore
    @State private var resources: [ResourceRecommendation] = []
    @State private var declined = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 10) {
                    StepBadge(symbol: "heart.text.square", text: "선택 사항")
                    Text("도움 자료가 필요하면 고르세요.")
                        .font(.title.weight(.black))
                        .foregroundStyle(Color.appTextPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("자동으로 보여주지 않아요. 지금 필요할 때만 열어볼게요.")
                        .font(.body.weight(.medium))
                        .foregroundStyle(Color.appTextSecondary)
                }

                VStack(spacing: 10) {
                    ForEach(ResourceType.allCases) { type in
                        optionButton(label: type.label, symbol: type.symbol) {
                            declined = false
                            resources = LocalCoach.resources(for: type)
                        }
                    }
                    optionButton(label: "지금은 괜찮아요", symbol: "checkmark") {
                        declined = true
                        resources = []
                    }
                }

                if declined {
                    Text("좋아요. 필요할 때 다시 요청해도 괜찮아요.")
                        .font(.body.weight(.medium))
                        .foregroundStyle(Color.appTextSecondary)
                        .card()
                }

                ForEach(resources) { resource in
                    resourceCard(resource)
                }
            }
            .padding(20)
        }
        .background(Color.appBackground)
        .navigationTitle("도움 자료")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            Button {
                flow.finishFlow()
            } label: {
                Text("처음으로 돌아가기")
            }
            .buttonStyle(LowPriorityButtonStyle())
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.bar)
        }
    }

    private func optionButton(label: String, symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(label, systemImage: symbol)
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

    private func resourceCard(_ resource: ResourceRecommendation) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(resource.type.label)
                .font(.footnote.weight(.bold))
                .foregroundStyle(Color.appAccent)
            Text(resource.title)
                .font(.title2.weight(.black))
                .foregroundStyle(Color.appTextPrimary)
            if let minutes = resource.durationMinutes {
                Text("\(minutes)분")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.appTextSecondary)
            }
            if let description = resource.description {
                Text(description)
                    .font(.body.weight(.medium))
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let reason = resource.reason {
                Text(reason)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.appTextSecondary)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.appMint)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .card()
    }
}
