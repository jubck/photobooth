import SwiftUI

struct ChooseFrameView: View {
    @EnvironmentObject private var session: PhotoBoothSession

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        PanelScreen(title: "choose your frame!", onClose: { session.backToReview() }) {
            VStack(spacing: 28) {
                LazyVGrid(columns: columns, spacing: 22) {
                    ForEach(FrameStyle.allCases) { frame in
                        swatch(for: frame)
                    }
                }
                .padding(.horizontal, 60)
                .padding(.top, 30)

                captionSection

                Button("apply") {
                    session.confirmFrame()
                }
                .buttonStyle(CuteButtonStyle(fill: Theme.yellow))

                Spacer()
            }
        }
    }

    private var captionSection: some View {
        VStack(spacing: 12) {
            Toggle(isOn: $session.captionEnabled) {
                Text("add a message (default applied)!")
                    .font(.appFont(16, weight: .bold))
                    .foregroundStyle(Theme.ink)
            }
            .toggleStyle(SwitchToggleStyle(tint: Theme.ink))

            if session.captionEnabled {
                TextField("message", text: $session.captionText)
                    .font(.appFont(16, weight: .medium))
                    .foregroundStyle(Theme.ink)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Theme.cream)
                    .cuteBorder(cornerRadius: 12, lineWidth: 2.5)

                Picker("text color", selection: $session.captionColor) {
                    ForEach(CaptionColor.allCases) { color in
                        Text(color.displayName).tag(color)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .padding(.horizontal, 80)
    }

    private func swatch(for frame: FrameStyle) -> some View {
        let isSelected = session.frameStyle == frame
        return Button {
            session.frameStyle = frame
        } label: {
            VStack(spacing: 8) {
                swatchPreview(for: frame)
                    .frame(width: 84, height: 84)
                    .cuteBorder(cornerRadius: 14, lineWidth: isSelected ? 4.5 : 2.5)
                Text(frame.displayName)
                    .font(.appFont(13, weight: .bold))
                    .foregroundStyle(Theme.ink)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.06 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.65), value: isSelected)
    }

    @ViewBuilder
    private func swatchPreview(for frame: FrameStyle) -> some View {
        if case .polkaDot(let dotColor) = frame {
            ZStack {
                Color.white
                PolkaDotPreview(color: Color(dotColor.uiColor))
            }
        } else if case .starPattern(let starColor) = frame {
            ZStack {
                Color.white
                StarFieldPreview(color: Color(starColor.uiColor))
            }
        } else if case .stripePattern(let stripe) = frame {
            let colors = stripe.colors
            StripePreview(color1: Color(colors.0), color2: Color(colors.1))
        } else {
            Color(frame.swatchColor)
        }
    }
}

private struct PolkaDotPreview: View {
    let color: Color

    var body: some View {
        GeometryReader { geo in
            let cols = 3
            let spacing = geo.size.width / CGFloat(cols)
            ForEach(0..<cols, id: \.self) { row in
                ForEach(0..<cols, id: \.self) { col in
                    Circle()
                        .fill(color)
                        .frame(width: spacing * 0.5, height: spacing * 0.5)
                        .position(x: spacing * (CGFloat(col) + 0.5), y: spacing * (CGFloat(row) + 0.5))
                }
            }
        }
    }
}

private struct StarFieldPreview: View {
    let color: Color

    var body: some View {
        GeometryReader { geo in
            let cols = 3
            let spacing = geo.size.width / CGFloat(cols)
            ForEach(0..<cols, id: \.self) { row in
                ForEach(0..<cols, id: \.self) { col in
                    Image(systemName: "star.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(color)
                        .frame(width: spacing * 0.55, height: spacing * 0.55)
                        .position(x: spacing * (CGFloat(col) + 0.5), y: spacing * (CGFloat(row) + 0.5))
                }
            }
        }
    }
}

private struct StripePreview: View {
    let color1: Color
    let color2: Color

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<6, id: \.self) { i in
                (i % 2 == 0 ? color1 : color2)
            }
        }
    }
}
