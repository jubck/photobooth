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

/// Steps back one screen. Used in every panel header and over the camera preview.
struct BackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "chevron.left")
                    .font(.appFont(14, weight: .black))
                Text("back")
                    .font(.appFont(16, weight: .bold))
            }
            .foregroundStyle(Theme.ink)
            .padding(.horizontal, 12)
            .frame(height: 36)
            .background(Theme.cream)
            .cuteBorder(cornerRadius: 10, lineWidth: 2.5)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("back")
    }
}

struct PanelScreen<Content: View>: View {
    let title: String
    /// Shows a back button in the header. Omit on the first screen.
    var onBack: (() -> Void)?
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                if let onBack {
                    BackButton(action: onBack)
                }
                Text(title)
                    .font(.appFont(28, weight: .bold))
                    .foregroundStyle(Theme.ink)
                Spacer()
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
