import SwiftUI

struct CuteBorder: ViewModifier {
    var cornerRadius: CGFloat = 18
    var lineWidth: CGFloat = 3

    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Theme.ink, lineWidth: lineWidth)
            )
    }
}

extension View {
    func cuteBorder(cornerRadius: CGFloat = 18, lineWidth: CGFloat = 3) -> some View {
        modifier(CuteBorder(cornerRadius: cornerRadius, lineWidth: lineWidth))
    }
}

struct CuteButtonStyle: ButtonStyle {
    var fill: Color = Theme.cream
    var textColor: Color = Theme.ink

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.appFont(18, weight: .bold))
            .foregroundStyle(textColor)
            .padding(.horizontal, 28)
            .padding(.vertical, 14)
            .background(fill)
            .cuteBorder(cornerRadius: 16, lineWidth: 3)
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct PanelScreen<Content: View>: View {
    let title: String
    var onClose: (() -> Void)?
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                    .font(.appFont(28, weight: .bold))
                    .foregroundStyle(Theme.ink)
                Spacer()
                if let onClose {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.appFont(14, weight: .black))
                            .foregroundStyle(.white)
                            .frame(width: 32, height: 32)
                            .background(Theme.accentRed)
                            .cuteBorder(cornerRadius: 8, lineWidth: 2.5)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 18)
            .background(Theme.headerPink)

            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Theme.cream)
        }
        .cuteBorder(cornerRadius: 24, lineWidth: 4)
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.backdrop)
    }
}
