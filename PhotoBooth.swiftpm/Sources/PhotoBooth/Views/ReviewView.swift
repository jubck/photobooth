import SwiftUI

struct ReviewView: View {
    @EnvironmentObject private var session: PhotoBoothSession

    var body: some View {
        PanelScreen(title: "how'd it turn out?", onBack: { session.retake() }) {
            VStack(spacing: 28) {
                HStack(spacing: 12) {
                    ForEach(Array(session.filteredImages.enumerated()), id: \.offset) { _, image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 130, height: 130)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(Theme.ink, lineWidth: 2.5)
                            )
                    }
                }
                .padding(.top, 30)

                HStack(spacing: 20) {
                    Button("retake") {
                        session.retake()
                    }
                    .buttonStyle(CuteButtonStyle(fill: Theme.cream))

                    Button("make strip") {
                        session.confirmReview()
                    }
                    .buttonStyle(CuteButtonStyle(fill: Theme.yellow))
                }

                Spacer()
            }
        }
    }
}
