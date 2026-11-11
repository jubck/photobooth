import UIKit

enum CaptionColor: String, CaseIterable, Identifiable, Hashable {
    case black
    case white

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .black: return "black"
        case .white: return "white"
        }
    }

    var uiColor: UIColor {
        switch self {
        case .black: return .black
        case .white: return .white
        }
    }
}
