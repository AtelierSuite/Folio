#if os(iOS)
import UIKit
import UniformTypeIdentifiers

extension MarkdownPastedImage {
    static var isAvailable: Bool {
        UIPasteboard.general.hasImages
    }

    /// Prefers the image's original encoding, falling back to a PNG of whatever image the pasteboard holds.
    static func fromPasteboard() -> MarkdownPastedImage? {
        let pasteboard = UIPasteboard.general
        guard pasteboard.hasImages else { return nil }
        for type in preferredTypes {
            if let data = pasteboard.data(forPasteboardType: type.identifier) {
                return MarkdownPastedImage(data: data, type: type, name: nil)
            }
        }
        guard let data = pasteboard.image?.pngData() else { return nil }
        return MarkdownPastedImage(data: data, type: .png, name: nil)
    }
}
#endif
