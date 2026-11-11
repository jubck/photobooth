import SwiftUI

@main
struct PhotoBoothApp: App {
    @StateObject private var session = PhotoBoothSession()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(session)
                .preferredColorScheme(.light)
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var session: PhotoBoothSession

    var body: some View {
        Group {
            switch session.stage {
            case .pickStyle:
                StylePickerView()
            case .capture:
                CaptureView()
            case .review:
                ReviewView()
            case .chooseFrame:
                ChooseFrameView()
            case .preview:
                PrintPreviewView()
            case .gallery:
                GalleryView()
            }
        }
        .animation(.easeInOut, value: session.stage)
    }
}
