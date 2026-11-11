import Photos
import UIKit

struct SavedStrip: Identifiable, Equatable {
    let asset: PHAsset

    var id: String { asset.localIdentifier }
    var date: Date { asset.creationDate ?? .distantPast }

    static func == (lhs: SavedStrip, rhs: SavedStrip) -> Bool {
        lhs.id == rhs.id
    }
}

/// Persists composed strips to a dedicated "PhotoBooth" album in the system Photos
/// library instead of the app's own sandbox, and reads them back via PHImageManager's
/// size-aware, caching thumbnail requests — avoiding the memory cost of decoding
/// every full-resolution print image just to show a small gallery thumbnail.
final class PhotoLibraryStore {
    static let shared = PhotoLibraryStore()

    private static let albumName = "PhotoBooth"
    private let imageManager = PHCachingImageManager()

    func save(_ image: UIImage) async {
        guard await ensureAuthorization() else { return }
        guard let album = await fetchOrCreateAlbum() else { return }
        try? await PHPhotoLibrary.shared().performChanges {
            let creationRequest = PHAssetCreationRequest.creationRequestForAsset(from: image)
            guard let placeholder = creationRequest.placeholderForCreatedAsset,
                  let albumChangeRequest = PHAssetCollectionChangeRequest(for: album) else { return }
            albumChangeRequest.addAssets([placeholder] as NSArray)
        }
    }

    func loadAll() async -> [SavedStrip] {
        guard await ensureAuthorization(), let album = fetchAlbum() else { return [] }
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let result = PHAsset.fetchAssets(in: album, options: options)
        var strips: [SavedStrip] = []
        result.enumerateObjects { asset, _, _ in
            strips.append(SavedStrip(asset: asset))
        }
        return strips
    }

    /// Removes the strip from the PhotoBooth album only — the photo itself stays
    /// safely in the user's main Photos library, not permanently deleted.
    func removeFromAlbum(_ asset: PHAsset) async {
        guard let album = fetchAlbum() else { return }
        try? await PHPhotoLibrary.shared().performChanges {
            guard let changeRequest = PHAssetCollectionChangeRequest(for: album) else { return }
            changeRequest.removeAssets([asset] as NSArray)
        }
    }

    func requestThumbnail(for asset: PHAsset, targetSize: CGSize) async -> UIImage? {
        await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.resizeMode = .fast
            options.isNetworkAccessAllowed = true
            imageManager.requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFit,
                options: options
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }

    func requestFullImage(for asset: PHAsset) async -> UIImage? {
        await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            imageManager.requestImage(
                for: asset,
                targetSize: PHImageManagerMaximumSize,
                contentMode: .aspectFit,
                options: options
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }

    private func ensureAuthorization() async -> Bool {
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .authorized, .limited:
            return true
        case .notDetermined:
            let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            return status == .authorized || status == .limited
        default:
            return false
        }
    }

    private func fetchAlbum() -> PHAssetCollection? {
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "title = %@", Self.albumName)
        return PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: options).firstObject
    }

    private func fetchOrCreateAlbum() async -> PHAssetCollection? {
        if let existing = fetchAlbum() { return existing }
        var placeholderIdentifier: String?
        try? await PHPhotoLibrary.shared().performChanges {
            let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: Self.albumName)
            placeholderIdentifier = request.placeholderForCreatedAssetCollection.localIdentifier
        }
        guard let id = placeholderIdentifier else { return nil }
        return PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [id], options: nil).firstObject
    }
}
