import SwiftUI

struct ScreenFlashOverlay: View {
    let isFlashing: Bool

    var body: some View {
        Color.white
            .opacity(isFlashing ? 1 : 0)
            .ignoresSafeArea()
            .allowsHitTesting(false)
            .animation(.easeOut(duration: 0.08), value: isFlashing)
    }
}
