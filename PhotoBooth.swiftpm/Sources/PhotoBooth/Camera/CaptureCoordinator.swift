import SwiftUI

@MainActor
final class CaptureCoordinator: ObservableObject {
    @Published var countdown: Int = 0
    @Published var isFlashing = false
    @Published var shotIndex = 0
    @Published var isCapturing = false

    let camera: CameraSessionController
    var totalShots = 4
    var onFinished: (([UIImage]) -> Void)?

    init(camera: CameraSessionController) {
        self.camera = camera
    }

    func start() {
        guard !isCapturing else { return }
        isCapturing = true
        Task { await runSequence() }
    }

    private func runSequence() async {
        var results: [UIImage] = []
        for index in 1...totalShots {
            shotIndex = index
            await countdownStep()
            let image = await flashAndCapture()
            if let image {
                results.append(image)
            }
            try? await Task.sleep(nanoseconds: 400_000_000)
        }
        isCapturing = false
        shotIndex = 0
        onFinished?(results)
    }

    private func countdownStep() async {
        for value in stride(from: 3, through: 1, by: -1) {
            countdown = value
            try? await Task.sleep(nanoseconds: 700_000_000)
        }
        countdown = 0
    }

    private func flashAndCapture() async -> UIImage? {
        isFlashing = true
        async let image = camera.capturePhoto()
        try? await Task.sleep(nanoseconds: 120_000_000)
        isFlashing = false
        return await image
    }
}
