import SwiftUI

enum AppStage {
    case pickStyle
    case capture
    case review
    case chooseFrame
    case preview
    case gallery
}

enum StripLength: Int, CaseIterable, Identifiable, Equatable {
    case three = 3
    case four = 4

    var id: Int { rawValue }
    var displayName: String { "\(rawValue) photos" }
}

@MainActor
final class PhotoBoothSession: ObservableObject {
    @Published var stage: AppStage = .pickStyle
    @Published var style: FilterStyle = .color
    @Published var stripLength: StripLength = .four
    @Published var frameStyle: FrameStyle = .white
    @Published var captionEnabled: Bool = false
    @Published var captionText: String = "julia's birthday bash <3"
    @Published var captionColor: CaptionColor = .black
    @Published var rawImages: [UIImage] = []
    @Published var filteredImages: [UIImage] = []
    @Published var composedSheet: UIImage?
    @Published var savedStrips: [SavedStrip] = []
    @Published var viewingSavedStrip: SavedStrip?

    /// The in-flight or finished auto-save of the current photos' strip, so a later
    /// re-apply of the frame can replace it instead of adding a duplicate.
    private var pendingSave: Task<String?, Never>?

    func reset() {
        rawImages = []
        filteredImages = []
        composedSheet = nil
        viewingSavedStrip = nil
        stage = .pickStyle
    }

    func chooseStyle(_ style: FilterStyle) {
        self.style = style
        rawImages = []
        stage = .capture
    }

    func captureFinished(images: [UIImage]) {
        rawImages = images
        filteredImages = images.map { VintageFilters.apply(style: style, to: $0) }
        pendingSave = nil // new photos: never replace a strip saved from earlier ones
        stage = .review
    }

    func retake() {
        rawImages = []
        filteredImages = []
        stage = .capture
    }

    func confirmReview() {
        stage = .chooseFrame
    }

    func backToReview() {
        stage = .review
    }

    func confirmFrame() {
        let caption = captionEnabled ? captionText : nil
        guard let sheet = StripComposer.composeSheet(
            from: filteredImages,
            frame: frameStyle,
            caption: caption,
            captionColor: captionColor
        ) else { return }
        composedSheet = sheet
        stage = .preview

        // The user can come back from the preview and apply a different frame. The
        // earlier version was already auto-saved, so take it out of the PhotoBooth
        // album (it stays in Photos, as with removing a strip from the gallery)
        // rather than listing the same photos twice.
        let previousSave = pendingSave
        pendingSave = Task {
            if let previousID = await previousSave?.value {
                await PhotoLibraryStore.shared.removeFromAlbum(localIdentifier: previousID)
            }
            return await PhotoLibraryStore.shared.save(sheet)
        }
    }

    func backToChooseFrame() {
        stage = .chooseFrame
    }

    func openGallery() {
        stage = .gallery
        Task {
            savedStrips = await PhotoLibraryStore.shared.loadAll()
        }
    }

    func closeGallery() {
        stage = .pickStyle
    }

    func deleteSavedStrip(_ strip: SavedStrip) {
        savedStrips.removeAll { $0.id == strip.id }
        Task {
            await PhotoLibraryStore.shared.removeFromAlbum(strip.asset)
        }
    }

    func viewSavedStrip(_ strip: SavedStrip) {
        viewingSavedStrip = strip
        composedSheet = nil
        stage = .preview
        Task {
            composedSheet = await PhotoLibraryStore.shared.requestFullImage(for: strip.asset)
        }
    }

    func backFromPreview() {
        if viewingSavedStrip != nil {
            viewingSavedStrip = nil
            openGallery()
        } else {
            reset()
        }
    }
}
