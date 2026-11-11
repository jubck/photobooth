enum FilterStyle: String, CaseIterable, Identifiable, Equatable {
    case blackAndWhite
    case color
    case sepia
    case faded
    case y2016

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .blackAndWhite: return "black & white"
        case .color: return "color"
        case .sepia: return "sepia"
        case .faded: return "faded"
        case .y2016: return "2016"
        }
    }

    var iconName: String {
        switch self {
        case .blackAndWhite: return "circle.lefthalf.filled"
        case .color: return "camera.filters"
        case .sepia: return "sun.dust.fill"
        case .faded: return "cloud.fill"
        case .y2016: return "bolt.fill"
        }
    }
}
