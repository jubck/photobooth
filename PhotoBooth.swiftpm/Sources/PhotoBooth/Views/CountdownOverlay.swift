import SwiftUI

struct CountdownOverlay: View {
    let count: Int

    var body: some View {
        if count > 0 {
            Text("\(count)")
                .font(.appFont(120, weight: .black))
                .foregroundStyle(Theme.ink)
                .frame(width: 220, height: 220)
                .background(Circle().fill(Theme.cream))
                .overlay(Circle().stroke(Theme.ink, lineWidth: 5))
                .shadow(radius: 10)
                .transition(.scale.combined(with: .opacity))
                .id(count)
        }
    }
}
