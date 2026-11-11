import SwiftUI

struct StylePickerView: View {
    @EnvironmentObject private var session: PhotoBoothSession

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        PanelScreen(title: "photobooth!") {
            VStack(spacing: 24) {
                Text("welcome to my photobooth!! theres a 3 second countdown between shots. enjoy!! =)")
                    .font(.appFont(16, weight: .medium))
                    .foregroundStyle(Theme.ink.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 50)
                    .padding(.top, 24)

                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(FilterStyle.allCases) { style in
                        styleTile(style)
                    }
                }
                .padding(.horizontal, 70)

                HStack(spacing: 16) {
                    ForEach(StripLength.allCases) { length in
                        lengthTile(length)
                    }
                }

                Button {
                    session.openGallery()
                } label: {
                    Label("my strips", systemImage: "square.grid.2x2.fill")
                }
                .buttonStyle(CuteButtonStyle(fill: Theme.panelPink))

                Spacer()
            }
        }
    }

    private func styleTile(_ style: FilterStyle) -> some View {
        Button {
            session.chooseStyle(style)
        } label: {
            VStack(spacing: 12) {
                Image(systemName: style.iconName)
                    .font(.system(size: 30))
                Text(style.displayName)
                    .font(.appFont(16, weight: .bold))
            }
            .foregroundStyle(Theme.ink)
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(Theme.yellow)
            .cuteBorder(cornerRadius: 18, lineWidth: 3)
        }
        .buttonStyle(.plain)
    }

    private func lengthTile(_ length: StripLength) -> some View {
        let isSelected = session.stripLength == length
        return Button {
            session.stripLength = length
        } label: {
            Text(length.displayName)
                .font(.appFont(15, weight: .bold))
                .foregroundStyle(Theme.ink)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(isSelected ? Theme.yellow : Theme.cream)
                .cuteBorder(cornerRadius: 14, lineWidth: isSelected ? 3.5 : 2)
        }
        .buttonStyle(.plain)
    }
}
