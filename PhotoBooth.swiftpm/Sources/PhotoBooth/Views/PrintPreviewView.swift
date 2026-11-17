import SwiftUI
import UIKit

struct PrintPreviewView: View {
    @EnvironmentObject private var session: PhotoBoothSession

    var body: some View {
        PanelScreen(title: "ready 2 print!!", onBack: goBack) {
            VStack(spacing: 24) {
                if let sheet = session.composedSheet {
                    Image(uiImage: sheet)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 420)
                        .background(Color.white)
                        .cuteBorder(cornerRadius: 10, lineWidth: 3)
                        .padding(.top, 24)
                } else {
                    ProgressView()
                        .tint(Theme.ink)
                        .frame(height: 420)
                        .padding(.top, 24)
                }

                Text("pick the canon selphy cp1300 as the printer. if you run into any issues ask julia for help =) all photos are saved locally in the app + the ipads photo gallery!!!!")
                    .font(.appFont(14, weight: .medium))
                    .foregroundStyle(Theme.ink.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 60)

                HStack(spacing: 20) {
                    Button(session.viewingSavedStrip != nil ? "back 2 strips" : "start over") {
                        session.backFromPreview()
                    }
                    .buttonStyle(CuteButtonStyle(fill: Theme.cream))

                    Button("print") {
                        printSheet()
                    }
                    .buttonStyle(CuteButtonStyle(fill: Theme.yellow))
                    .disabled(session.composedSheet == nil)
                }

                Spacer()
            }
        }
    }

    /// A strip opened from the gallery goes back to the gallery; a freshly made one
    /// goes back to frame selection so the frame or message can be changed without
    /// retaking the photos ("start over" is still the way to begin a new strip).
    private func goBack() {
        if session.viewingSavedStrip != nil {
            session.backFromPreview()
        } else {
            session.backToChooseFrame()
        }
    }

    private func printSheet() {
        guard let sheet = session.composedSheet,
              let window = UIApplication.shared.connectedScenes
                  .compactMap({ $0 as? UIWindowScene })
                  .first?.windows.first(where: { $0.isKeyWindow }) else { return }
        PrintManager.printSheet(sheet, from: window)
    }
}
