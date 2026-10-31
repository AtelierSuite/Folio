#if os(macOS)
import AppKit
import UniformTypeIdentifiers

extension MarkdownPastedImage {
    private static var pasteboardTypes: [NSPasteboard.PasteboardType] {
        preferredTypes.map { NSPasteboard.PasteboardType($0.identifier) }
    }

    private static let imageFileOptions: [NSPasteboard.ReadingOptionKey: Any] = [
        .urlReadingFileURLsOnly: true,
        .urlReadingContentsConformToTypes: [UTType.image.identifier]
    ]

    static var isAvailable: Bool {
        let pasteboard = NSPasteboard.general
        return pasteboard.availableType(from: pasteboardTypes) != nil
            || pasteboard.canReadObject(forClasses: [NSURL.self], options: imageFileOptions)
    }

    /// Image files copied in Finder keep their name; image data, such as a screenshot, keeps its encoding.
    static func fromPasteboard() -> MarkdownPastedImage? {
        let pasteboard = NSPasteboard.general
        if let url = (pasteboard.readObjects(forClasses: [NSURL.self], options: imageFileOptions) as? [URL])?.first,
           let data = try? Data(contentsOf: url) {
            let type = UTType(filenameExtension: url.pathExtension)
            return MarkdownPastedImage(data: data, type: type, name: url.lastPathComponent)
        }
        guard let type = pasteboard.availableType(from: pasteboardTypes),
              let data = pasteboard.data(forType: type) else {
            return nil
        }
        return MarkdownPastedImage(data: data, type: UTType(type.rawValue), name: nil)
    }
}
#endif
