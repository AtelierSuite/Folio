import SwiftUI
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

struct MarkdownLoadedImage {
    let image: Image
    let size: CGSize

    static func load(from url: URL) async -> MarkdownLoadedImage? {
        guard let data = await data(at: url) else { return nil }
        #if canImport(UIKit)
        guard let platformImage = UIImage(data: data) else { return nil }
        return MarkdownLoadedImage(image: Image(uiImage: platformImage), size: platformImage.size)
        #else
        guard let platformImage = NSImage(data: data) else { return nil }
        return MarkdownLoadedImage(image: Image(nsImage: platformImage), size: platformImage.size)
        #endif
    }

    @concurrent
    private nonisolated static func data(at url: URL) async -> Data? {
        try? await URLSession.shared.data(from: url).0
    }
}
