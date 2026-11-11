import SwiftUI

enum Theme {
    static let backdrop = Color(red: 0.98, green: 0.89, blue: 0.83)
    static let cream = Color(red: 1.0, green: 0.96, blue: 0.92)
    static let headerPink = Color(red: 0.96, green: 0.66, blue: 0.72)
    static let panelPink = Color(red: 0.97, green: 0.76, blue: 0.81)
    static let accentRed = Color(red: 0.95, green: 0.33, blue: 0.36)
    static let ink = Color(red: 0.35, green: 0.13, blue: 0.19)
    static let yellow = Color(red: 0.97, green: 0.79, blue: 0.28)
}

extension Font {
    static func appFont(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}
