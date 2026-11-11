import UIKit

enum FrameStyle: Identifiable, Equatable, Hashable {
    case white
    case pink
    case black
    case yellow
    case teal
    case polkaDot(DotColor)
    case starPattern(DotColor)
    case stripePattern(StripeColors)

    enum DotColor: String, CaseIterable, Identifiable, Hashable {
        case pink
        case blue
        case lavender
        case mint

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .pink: return "pink"
            case .blue: return "blue"
            case .lavender: return "lavender"
            case .mint: return "mint"
            }
        }

        var uiColor: UIColor {
            switch self {
            case .pink: return UIColor(red: 0.97, green: 0.75, blue: 0.83, alpha: 1)
            case .blue: return UIColor(red: 0.70, green: 0.84, blue: 0.95, alpha: 1)
            case .lavender: return UIColor(red: 0.83, green: 0.78, blue: 0.94, alpha: 1)
            case .mint: return UIColor(red: 0.75, green: 0.91, blue: 0.84, alpha: 1)
            }
        }
    }

    enum StripeColors: String, CaseIterable, Identifiable, Hashable {
        case greenPink
        case blueWhite
        case pinkWhite
        case yellowWhite

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .greenPink: return "green & pink"
            case .blueWhite: return "blue & white"
            case .pinkWhite: return "pink & white"
            case .yellowWhite: return "yellow & white"
            }
        }

        var colors: (UIColor, UIColor) {
            let pastelGreen = UIColor(red: 0.75, green: 0.91, blue: 0.84, alpha: 1)
            let pastelPink = UIColor(red: 0.97, green: 0.75, blue: 0.83, alpha: 1)
            let pastelBlue = UIColor(red: 0.70, green: 0.84, blue: 0.95, alpha: 1)
            let pastelYellow = UIColor(red: 0.99, green: 0.90, blue: 0.66, alpha: 1)
            switch self {
            case .greenPink: return (pastelGreen, pastelPink)
            case .blueWhite: return (pastelBlue, .white)
            case .pinkWhite: return (pastelPink, .white)
            case .yellowWhite: return (pastelYellow, .white)
            }
        }
    }

    static var allCases: [FrameStyle] {
        [.white, .pink, .black, .yellow, .teal]
            + DotColor.allCases.map { .polkaDot($0) }
            + DotColor.allCases.map { .starPattern($0) }
            + StripeColors.allCases.map { .stripePattern($0) }
    }

    var id: String {
        switch self {
        case .white: return "white"
        case .pink: return "pink"
        case .black: return "black"
        case .yellow: return "yellow"
        case .teal: return "teal"
        case .polkaDot(let color): return "polkaDot-\(color.rawValue)"
        case .starPattern(let color): return "starPattern-\(color.rawValue)"
        case .stripePattern(let stripe): return "stripePattern-\(stripe.rawValue)"
        }
    }

    var displayName: String {
        switch self {
        case .white: return "white"
        case .pink: return "pink"
        case .black: return "black"
        case .yellow: return "yellow"
        case .teal: return "teal"
        case .polkaDot(let color): return "\(color.displayName) dots"
        case .starPattern(let color): return "\(color.displayName) stars"
        case .stripePattern(let stripe): return stripe.displayName
        }
    }

    var swatchColor: UIColor {
        switch self {
        case .white, .polkaDot, .starPattern, .stripePattern: return .white
        case .pink: return UIColor(red: 0.96, green: 0.69, blue: 0.77, alpha: 1)
        case .black: return .black
        case .yellow: return UIColor(red: 0.98, green: 0.80, blue: 0.27, alpha: 1)
        case .teal: return UIColor(red: 0x15 / 255.0, green: 0xA3 / 255.0, blue: 0xC7 / 255.0, alpha: 1)
        }
    }

    func drawBackground(in rect: CGRect) {
        swatchColor.setFill()
        UIRectFill(rect)
    }

    func drawPattern(in rect: CGRect, scale: CGFloat) {
        switch self {
        case .polkaDot(let color):
            color.uiColor.setFill()
            drawShapeField(in: rect, diameter: scale) { center, radius in
                UIBezierPath(ovalIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
            }
        case .starPattern(let color):
            color.uiColor.setFill()
            drawShapeField(in: rect, diameter: scale) { center, radius in
                Self.starPath(center: center, outerRadius: radius)
            }
        case .stripePattern(let stripe):
            let (color1, color2) = stripe.colors
            drawStripes(in: rect, color1: color1, color2: color2, stripeWidth: scale * 2.2)
        default:
            break
        }
    }

    private func drawStripes(in rect: CGRect, color1: UIColor, color2: UIColor, stripeWidth: CGFloat) {
        guard rect.width > 0, rect.height > 0, stripeWidth > 0 else { return }
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        context?.clip(to: rect)

        var x = rect.minX
        var index = 0
        while x < rect.maxX {
            let color = (index % 2 == 0) ? color1 : color2
            color.setFill()
            UIRectFill(CGRect(x: x, y: rect.minY, width: stripeWidth, height: rect.height))
            x += stripeWidth
            index += 1
        }

        context?.restoreGState()
    }

    private func drawShapeField(in rect: CGRect, diameter: CGFloat, shape: (CGPoint, CGFloat) -> UIBezierPath) {
        guard rect.width > 0, rect.height > 0 else { return }

        let horizontalSpacing = diameter * 1.7
        let verticalSpacing = diameter * 1.47

        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        context?.clip(to: rect)

        var row = 0
        var centerY = rect.minY
        while centerY < rect.maxY + diameter {
            let rowOffset = (row % 2 == 0) ? 0 : horizontalSpacing / 2
            var centerX = rect.minX + rowOffset - horizontalSpacing
            while centerX < rect.maxX + diameter {
                shape(CGPoint(x: centerX, y: centerY), diameter / 2).fill()
                centerX += horizontalSpacing
            }
            centerY += verticalSpacing
            row += 1
        }

        context?.restoreGState()
    }

    private static func starPath(center: CGPoint, outerRadius: CGFloat) -> UIBezierPath {
        let points = 5
        let innerRadius = outerRadius * 0.45
        let path = UIBezierPath()
        let angleStep = CGFloat.pi / CGFloat(points)

        for i in 0..<(points * 2) {
            let radius = (i % 2 == 0) ? outerRadius : innerRadius
            let angle = CGFloat(i) * angleStep - .pi / 2
            let point = CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.close()
        return path
    }
}
