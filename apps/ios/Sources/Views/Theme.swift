import SwiftUI

extension Color {
    init(light: String, dark: String) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light)
        })
    }

    static let appBackground = Color(light: "FBF8F4", dark: "151816")
    static let appCard = Color(light: "FFFFFF", dark: "1F2420")
    static let appPrimary = Color(light: "25342D", dark: "33463D")
    static let appAccent = Color(light: "C56F5C", dark: "D98A76")
    static let appTextPrimary = Color(light: "0F1512", dark: "F2F0EA")
    static let appTextSecondary = Color(light: "46564E", dark: "A8B5AC")
    static let appMint = Color(light: "EEF4EB", dark: "26302A")
    static let appWarnBackground = Color(light: "FFF1EA", dark: "3A2620")
    static let appWarnText = Color(light: "994838", dark: "E2A18F")
    static let appBorder = Color(light: "E2E8F0", dark: "343B36")
}

extension UIColor {
    convenience init(hex: String) {
        var value: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&value)
        self.init(
            red: CGFloat((value >> 16) & 0xFF) / 255,
            green: CGFloat((value >> 8) & 0xFF) / 255,
            blue: CGFloat(value & 0xFF) / 255,
            alpha: 1
        )
    }
}

/// 화면당 1개의 큰 주요 행동 버튼.
struct PrimaryButtonStyle: ButtonStyle {
    var isEnabled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3.weight(.bold))
            .frame(maxWidth: .infinity, minHeight: 60)
            .background(isEnabled ? Color.appPrimary : Color.appBorder)
            .foregroundStyle(isEnabled ? Color.white : Color.appTextSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3.weight(.bold))
            .frame(maxWidth: .infinity, minHeight: 60)
            .background(Color.appCard)
            .foregroundStyle(Color.appTextPrimary)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color.appBorder, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

struct LowPriorityButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.bold))
            .frame(maxWidth: .infinity, minHeight: 52)
            .foregroundStyle(Color.appTextSecondary)
            .contentShape(Rectangle())
            .opacity(configuration.isPressed ? 0.65 : 1)
    }
}

struct CompactActionButtonStyle: ButtonStyle {
    var foreground: Color = .appTextPrimary
    var background: Color = .appCard

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.bold))
            .frame(maxWidth: .infinity, minHeight: 52)
            .padding(.horizontal, 12)
            .background(background)
            .foregroundStyle(foreground)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.appBorder, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

struct CardBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.appCard)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color.appBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

extension View {
    func card() -> some View {
        modifier(CardBackground())
    }
}

/// 단계 라벨 (예: "1단계 · 털어놓기")
struct StepBadge: View {
    let symbol: String
    let text: String

    var body: some View {
        Label(text, systemImage: symbol)
            .font(.subheadline.weight(.bold))
            .foregroundStyle(Color.appAccent)
    }
}

/// 0~10 감정 점수 그리드.
struct ScoreGrid: View {
    let onSelect: (Int) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(0...10, id: \.self) { score in
                Button {
                    onSelect(score)
                } label: {
                    Text("\(score)")
                        .font(.title.weight(.black))
                        .frame(maxWidth: .infinity, minHeight: 76)
                        .background(background(for: score))
                        .foregroundStyle(foreground(for: score))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(border(for: score), lineWidth: 2)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .accessibilityLabel("\(score)점")
            }
        }
    }

    private func background(for score: Int) -> Color {
        score >= 7 ? .appWarnBackground : .appCard
    }

    private func foreground(for score: Int) -> Color {
        if score >= 7 { return .appWarnText }
        if score >= 4 { return .appTextPrimary }
        return .appTextSecondary
    }

    private func border(for score: Int) -> Color {
        score >= 7 ? Color.appWarnText.opacity(0.4) : .appBorder
    }
}
