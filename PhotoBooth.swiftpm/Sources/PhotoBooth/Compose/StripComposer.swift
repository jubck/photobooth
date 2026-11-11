import UIKit

enum StripComposer {
    private static let dpi: CGFloat = 300
    private static let stripSize = CGSize(width: 2 * dpi, height: 6 * dpi)
    private static let margin: CGFloat = dpi * 0.3
    private static let bottomMargin: CGFloat = dpi * 0.45
    private static let divider: CGFloat = dpi * 0.05

    static func composeSheet(
        from images: [UIImage],
        frame: FrameStyle,
        caption: String?,
        captionColor: CaptionColor
    ) -> UIImage? {
        guard images.count == 3 || images.count == 4 else { return nil }
        let strip = composeStrip(from: images, frame: frame, caption: caption, captionColor: captionColor)

        let finalSize = CGSize(width: stripSize.width * 2, height: stripSize.height)
        let renderer = UIGraphicsImageRenderer(size: finalSize)
        return renderer.image { _ in
            strip.draw(at: CGPoint(x: 0, y: 0))
            strip.draw(at: CGPoint(x: stripSize.width, y: 0))
        }
    }

    private static func composeStrip(
        from images: [UIImage],
        frame: FrameStyle,
        caption: String?,
        captionColor: CaptionColor
    ) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: stripSize)
        return renderer.image { context in
            let fullRect = CGRect(origin: .zero, size: stripSize)
            frame.drawBackground(in: fullRect)
            frame.drawPattern(in: fullRect, scale: margin * 0.4)

            let hasCaption = !(caption?.isEmpty ?? true)
            let slotCount = hasCaption ? images.count + 1 : images.count

            let innerWidth = stripSize.width - margin * 2
            let totalDividers = divider * CGFloat(slotCount - 1)
            let slotsAreaHeight = stripSize.height - margin - totalDividers - bottomMargin
            let slotHeight = slotsAreaHeight / CGFloat(slotCount)

            var y = margin
            for image in images {
                let photoFrame = CGRect(x: margin, y: y, width: innerWidth, height: slotHeight)
                UIColor.black.setFill()
                context.fill(photoFrame.insetBy(dx: -2, dy: -2))
                drawAspectFill(image, in: photoFrame)
                y += slotHeight + divider
            }

            if hasCaption, let caption {
                let captionRect = CGRect(x: margin, y: y, width: innerWidth, height: slotHeight)
                drawCaption(caption, in: captionRect, color: captionColor.uiColor)
            }
        }
    }

    private static func drawCaption(_ text: String, in rect: CGRect, color: UIColor) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineBreakMode = .byWordWrapping

        let layoutOptions: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        let constrainingSize = CGSize(width: rect.width, height: .greatestFiniteMagnitude)

        var fontSize = rect.height * 0.26
        let minFontSize = rect.height * 0.08
        var font = captionFont(size: fontSize)
        var wrappedSize = CGSize.zero

        while fontSize >= minFontSize {
            font = captionFont(size: fontSize)
            let probe = NSAttributedString(string: text, attributes: [.font: font, .paragraphStyle: paragraph])
            wrappedSize = probe.boundingRect(with: constrainingSize, options: layoutOptions, context: nil).size
            if wrappedSize.height <= rect.height { break }
            fontSize -= 2
        }

        let finalSize = CGSize(width: rect.width, height: min(wrappedSize.height.rounded(.up), rect.height))
        guard finalSize.width > 0, finalSize.height > 0 else { return }

        let attributed = NSAttributedString(string: text, attributes: [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraph
        ])

       
        let textImage = UIGraphicsImageRenderer(size: finalSize).image { _ in
            attributed.draw(with: CGRect(origin: .zero, size: finalSize), options: layoutOptions, context: nil)
        }

        let origin = CGPoint(
            x: rect.midX - finalSize.width / 2,
            y: rect.midY - finalSize.height / 2
        )
        textImage.draw(at: origin)
    }

    private static func captionFont(size: CGFloat) -> UIFont {
        let base = UIFont.systemFont(ofSize: size, weight: .bold)
        return base.fontDescriptor.withDesign(.rounded).map { UIFont(descriptor: $0, size: size) } ?? base
    }

    private static func drawAspectFill(_ image: UIImage, in rect: CGRect) {
        let imageSize = image.size
        guard imageSize.width > 0, imageSize.height > 0 else { return }
        let imageAspect = imageSize.width / imageSize.height
        let rectAspect = rect.width / rect.height

        var drawSize = rect.size
        if imageAspect > rectAspect {
            drawSize.width = rect.height * imageAspect
            drawSize.height = rect.height
        } else {
            drawSize.height = rect.width / imageAspect
            drawSize.width = rect.width
        }

        let origin = CGPoint(
            x: rect.midX - drawSize.width / 2,
            y: rect.midY - drawSize.height / 2
        )

        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        context?.clip(to: rect)
        image.draw(in: CGRect(origin: origin, size: drawSize))
        context?.restoreGState()
    }
}
