import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

enum VintageFilters {
    private static let context: CIContext = {
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB()
        return CIContext(options: [.workingColorSpace: colorSpace, .outputColorSpace: colorSpace])
    }()

    static func apply(style: FilterStyle, to image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        let input = CIImage(cgImage: cgImage)
        let output: CIImage
        switch style {
        case .blackAndWhite:
            output = blackAndWhite(input)
        case .color:
            output = colorVintage(input)
        case .sepia:
            output = sepia(input)
        case .faded:
            output = faded(input)
        case .y2016:
            output = y2016(input)
        }
        guard let rendered = context.createCGImage(output, from: input.extent) else { return image }
        return UIImage(cgImage: rendered, scale: image.scale, orientation: image.imageOrientation)
    }

    private static func blackAndWhite(_ input: CIImage) -> CIImage {
        var image = input

        let controls = CIFilter.colorControls()
        controls.inputImage = image
        controls.saturation = 0
        controls.contrast = 1.2
        image = controls.outputImage ?? image

        image = toneCurve(image, points: [
            CGPoint(x: 0, y: 0.02),
            CGPoint(x: 0.25, y: 0.20),
            CGPoint(x: 0.5, y: 0.50),
            CGPoint(x: 0.75, y: 0.85),
            CGPoint(x: 1, y: 1.0)
        ])

        image = vignette(image, intensity: 0.5, falloff: 0.4, radiusScale: 0.8)
        return image
    }

    private static func colorVintage(_ input: CIImage) -> CIImage {
        var image = input

        let controls = CIFilter.colorControls()
        controls.inputImage = image
        controls.saturation = 0.82
        controls.contrast = 0.94
        controls.brightness = 0.02
        image = controls.outputImage ?? image

        image = toneCurve(image, points: [
            CGPoint(x: 0, y: 0.03),
            CGPoint(x: 0.25, y: 0.22),
            CGPoint(x: 0.5, y: 0.50),
            CGPoint(x: 0.75, y: 0.84),
            CGPoint(x: 1, y: 1.0)
        ])

        let matrix = CIFilter.colorMatrix()
        matrix.inputImage = image
        matrix.rVector = CIVector(x: 1, y: 0, z: 0, w: 0)
        matrix.gVector = CIVector(x: 0, y: 1, z: 0, w: 0)
        matrix.bVector = CIVector(x: 0, y: 0, z: 1, w: 0)
        matrix.biasVector = CIVector(x: 0.02, y: 0.01, z: -0.02, w: 0)
        image = matrix.outputImage ?? image

        image = vignette(image, intensity: 0.3, falloff: 0.5, radiusScale: 0.85)
        image = lightLeak(image)
        return image
    }

    private static func sepia(_ input: CIImage) -> CIImage {
        var image = input

        let controls = CIFilter.colorControls()
        controls.inputImage = image
        controls.saturation = 0
        controls.contrast = 1.1
        image = controls.outputImage ?? image

        let sepia = CIFilter.sepiaTone()
        sepia.inputImage = image
        sepia.intensity = 0.85
        image = sepia.outputImage ?? image

        image = toneCurve(image, points: [
            CGPoint(x: 0, y: 0.03),
            CGPoint(x: 0.25, y: 0.22),
            CGPoint(x: 0.5, y: 0.50),
            CGPoint(x: 0.75, y: 0.85),
            CGPoint(x: 1, y: 1.0)
        ])

        image = vignette(image, intensity: 0.45, falloff: 0.4, radiusScale: 0.8)
        return image
    }

    private static func faded(_ input: CIImage) -> CIImage {
        var image = input

        let controls = CIFilter.colorControls()
        controls.inputImage = image
        controls.saturation = 0.7
        controls.contrast = 0.85
        controls.brightness = 0.04
        image = controls.outputImage ?? image

        image = toneCurve(image, points: [
            CGPoint(x: 0, y: 0.12),
            CGPoint(x: 0.25, y: 0.30),
            CGPoint(x: 0.5, y: 0.54),
            CGPoint(x: 0.75, y: 0.80),
            CGPoint(x: 1, y: 0.98)
        ])

        return image
    }

    private static func y2016(_ input: CIImage) -> CIImage {
        var image = input

        let controls = CIFilter.colorControls()
        controls.inputImage = image
        controls.saturation = 1.4
        controls.contrast = 1.22
        controls.brightness = -0.02
        image = controls.outputImage ?? image

        
        let vibrance = CIFilter.vibrance()
        vibrance.inputImage = image
        vibrance.amount = 0.6
        image = vibrance.outputImage ?? image

       
        image = toneCurve(image, points: [
            CGPoint(x: 0, y: 0.0),
            CGPoint(x: 0.25, y: 0.13),
            CGPoint(x: 0.5, y: 0.48),
            CGPoint(x: 0.75, y: 0.80),
            CGPoint(x: 1, y: 1.0)
        ])

        image = purplePinkOverlay(image)

        let sharpen = CIFilter.sharpenLuminance()
        sharpen.inputImage = image
        sharpen.sharpness = 0.6
        image = sharpen.outputImage ?? image

        image = vignette(image, intensity: 0.25, falloff: 0.55, radiusScale: 0.9)
        return image
    }

    private static func toneCurve(_ image: CIImage, points: [CGPoint]) -> CIImage {
        let curve = CIFilter.toneCurve()
        curve.inputImage = image
        curve.point0 = points[0]
        curve.point1 = points[1]
        curve.point2 = points[2]
        curve.point3 = points[3]
        curve.point4 = points[4]
        return curve.outputImage ?? image
    }

    private static func vignette(_ image: CIImage, intensity: Float, falloff: Float, radiusScale: Float) -> CIImage {
        let effect = CIFilter.vignetteEffect()
        effect.inputImage = image
        effect.center = CGPoint(x: image.extent.midX, y: image.extent.midY)
        let diagonal = Float(hypot(image.extent.width, image.extent.height))
        effect.radius = diagonal * radiusScale
        effect.intensity = intensity
        effect.falloff = falloff
        return effect.outputImage?.cropped(to: image.extent) ?? image
    }

    private static func purplePinkOverlay(_ image: CIImage) -> CIImage {
        let gradient = CIFilter.linearGradient()
        gradient.point0 = CGPoint(x: image.extent.minX, y: image.extent.maxY)
        gradient.point1 = CGPoint(x: image.extent.maxX, y: image.extent.minY)
        gradient.color0 = CIColor(red: 0.45, green: 0.12, blue: 0.55, alpha: 0.42)
        gradient.color1 = CIColor(red: 0.95, green: 0.2, blue: 0.55, alpha: 0.42)

        guard let wash = gradient.outputImage?.cropped(to: image.extent) else { return image }

        let blend = CIFilter.sourceOverCompositing()
        blend.inputImage = wash
        blend.backgroundImage = image
        return blend.outputImage?.cropped(to: image.extent) ?? image
    }

    private static func lightLeak(_ image: CIImage) -> CIImage {
        let gradient = CIFilter.radialGradient()
        gradient.center = CGPoint(x: image.extent.maxX * 0.9, y: image.extent.maxY * 0.9)
        gradient.radius0 = 0
        gradient.radius1 = Float(max(image.extent.width, image.extent.height)) * 0.6
        gradient.color0 = CIColor(red: 1, green: 0.6, blue: 0.3, alpha: 0.35)
        gradient.color1 = CIColor(red: 1, green: 0.6, blue: 0.3, alpha: 0)

        guard let leak = gradient.outputImage?.cropped(to: image.extent) else { return image }
        let blurred = leak.applyingGaussianBlur(sigma: 60).cropped(to: image.extent)

        let blend = CIFilter.screenBlendMode()
        blend.inputImage = blurred
        blend.backgroundImage = image
        return blend.outputImage?.cropped(to: image.extent) ?? image
    }
}
