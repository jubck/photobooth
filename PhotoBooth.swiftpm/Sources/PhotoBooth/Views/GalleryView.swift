import SwiftUI

struct GalleryView: View {
    @EnvironmentObject private var session: PhotoBoothSession
    @State private var pendingDelete: SavedStrip?

    private let columns = [GridItem(.adaptive(minimum: 140), spacing: 16)]

    var body: some View {
        PanelScreen(title: "my strips", onBack: { session.closeGallery() }) {
            if session.savedStrips.isEmpty {
                VStack(spacing: 12) {
                    Text("no strips yet =(")
                        .font(.appFont(22, weight: .bold))
                        .foregroundStyle(Theme.ink)
                    Text("take your first photobooth strip to see it here!!")
                        .font(.appFont(15, weight: .medium))
                        .foregroundStyle(Theme.ink.opacity(0.6))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(session.savedStrips) { strip in
                            thumbnailCell(for: strip)
                        }
                    }
                    .padding(20)
                }
            }
        }
        .alert("remove this strip?", isPresented: Binding(
            get: { pendingDelete != nil },
            set: { if !$0 { pendingDelete = nil } }
        )) {
            Button("remove", role: .destructive) {
                if let strip = pendingDelete {
                    session.deleteSavedStrip(strip)
                }
                pendingDelete = nil
            }
            Button("Cancel", role: .cancel) {
                pendingDelete = nil
            }
        } message: {
            Text("this removes it from the PhotoBooth gallery. The photo stays in the Photos library.")
        }
    }

    private func thumbnailCell(for strip: SavedStrip) -> some View {
        ZStack(alignment: .topTrailing) {
            Button {
                session.viewSavedStrip(strip)
            } label: {
                StripThumbnailView(strip: strip)
            }
            .buttonStyle(.plain)

            Button {
                pendingDelete = strip
            } label: {
                Image(systemName: "trash.fill")
                    .font(.appFont(13, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(Theme.accentRed)
                    .cuteBorder(cornerRadius: 8, lineWidth: 2)
            }
            .buttonStyle(.plain)
            .padding(6)
        }
    }
}

/// Loads its own downsized thumbnail on appear instead of decoding the full
/// print-resolution image — keeps a scrolling grid of many strips cheap to hold
/// in memory.
private struct StripThumbnailView: View {
    let strip: SavedStrip
    @State private var thumbnail: UIImage?

    var body: some View {
        Group {
            if let thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFit()
            } else {
                Color.gray.opacity(0.15)
            }
        }
        .frame(height: 160)
        .frame(maxWidth: .infinity)
        .background(Theme.cream)
        .cuteBorder(cornerRadius: 14, lineWidth: 3)
        .task(id: strip.id) {
            thumbnail = await PhotoLibraryStore.shared.requestThumbnail(
                for: strip.asset,
                targetSize: CGSize(width: 280, height: 420)
            )
        }
    }
}
