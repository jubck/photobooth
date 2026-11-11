import SwiftUI
import AVFoundation

struct CaptureView: View {
    @EnvironmentObject private var session: PhotoBoothSession
    @StateObject private var camera: CameraSessionController
    @StateObject private var coordinator: CaptureCoordinator

    init() {
        let camera = CameraSessionController()
        _camera = StateObject(wrappedValue: camera)
        _coordinator = StateObject(wrappedValue: CaptureCoordinator(camera: camera))
    }

    var body: some View {
        ZStack {
            CameraPreview(session: camera.session)
                .ignoresSafeArea()

            VStack {
                Text("shot \(min(coordinator.shotIndex, coordinator.totalShots)) of \(coordinator.totalShots)")
                    .font(.appFont(16, weight: .bold))
                    .foregroundStyle(Theme.ink)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Theme.cream)
                    .cuteBorder(cornerRadius: 12, lineWidth: 2.5)
                    .opacity(coordinator.isCapturing ? 1 : 0)
                    .padding(.top, 24)
                Spacer()
            }

            CountdownOverlay(count: coordinator.countdown)

            ScreenFlashOverlay(isFlashing: coordinator.isFlashing)

            if !coordinator.isCapturing {
                VStack {
                    Spacer()
                    Button("start") {
                        coordinator.start()
                    }
                    .buttonStyle(CuteButtonStyle(fill: Theme.yellow))
                    .padding(.bottom, 60)
                }
            }
        }
        .task {
            await camera.requestAccessAndConfigure()
            camera.start()
        }
        .onDisappear {
            camera.stop()
        }
        .onAppear {
            coordinator.totalShots = session.stripLength.rawValue
            coordinator.onFinished = { images in
                session.captureFinished(images: images)
            }
        }
    }
}

private struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewUIView {
        let view = PreviewUIView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewUIView, context: Context) {}
}

private final class PreviewUIView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
}
