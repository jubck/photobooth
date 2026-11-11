import UIKit

enum PrintManager {
    @MainActor
    static func printSheet(_ image: UIImage, from sourceView: UIView) {
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .photo
        printInfo.jobName = "photobooth strip"
        printInfo.duplex = .none

        let controller = UIPrintInteractionController.shared
        controller.printInfo = printInfo
        controller.printingItem = image

        controller.present(
            from: sourceView.bounds,
            in: sourceView,
            animated: true,
            completionHandler: nil
        )
    }
}
