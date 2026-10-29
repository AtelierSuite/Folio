#if os(iOS)
import SwiftUI
import UIKit

/// A UIKit long press, so the drag only lifts after a hold: taps still select, and once it has
/// begun the scroll view's pan can no longer take the touch.
struct TimelineLongPressDragRecognizer: UIGestureRecognizerRepresentable {
    let isEnabled: Bool
    let onBegan: (CGPoint) -> Bool
    let onChanged: (CGPoint) -> Void
    let onEnded: () -> Void

    func makeUIGestureRecognizer(context: Context) -> UILongPressGestureRecognizer {
        let recognizer = UILongPressGestureRecognizer()
        recognizer.minimumPressDuration = 0.4
        recognizer.isEnabled = isEnabled
        return recognizer
    }

    func updateUIGestureRecognizer(_ recognizer: UILongPressGestureRecognizer, context: Context) {
        if recognizer.isEnabled != isEnabled { recognizer.isEnabled = isEnabled }
    }

    func handleUIGestureRecognizerAction(_ recognizer: UILongPressGestureRecognizer, context: Context) {
        let location = context.converter.location(in: TimelineDragController.coordinateSpace)
        switch recognizer.state {
        case .began:
            if !onBegan(location) {
                recognizer.isEnabled = false
                recognizer.isEnabled = true
            }
        case .changed:
            onChanged(location)
        case .ended, .cancelled, .failed:
            onEnded()
        default:
            break
        }
    }
}
#endif
