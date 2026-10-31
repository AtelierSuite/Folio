import Foundation
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

extension NSTextLayoutManager {
    /// The frame, in text container coordinates, of the first line a character range sits on. Off-screen
    /// text only has estimated positions until it is laid out, so callers lay out the document first.
    func frame(ofCharacterRange range: NSRange) -> CGRect? {
        guard let contentManager = textContentManager,
              let start = contentManager.location(documentRange.location, offsetBy: range.location),
              let end = contentManager.location(start, offsetBy: range.length),
              let textRange = NSTextRange(location: start, end: end) else {
            return nil
        }
        var frame: CGRect?
        enumerateTextSegments(in: textRange, type: .standard, options: .rangeNotRequired) { _, segmentFrame, _, _ in
            frame = segmentFrame
            return false
        }
        return frame
    }
}
