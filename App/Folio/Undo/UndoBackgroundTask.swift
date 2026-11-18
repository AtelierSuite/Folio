#if os(iOS)
import UIKit

/// Keeps the app running while staged deletes are written, ending the task exactly once
/// whether the write finishes or iOS runs out of background time first.
final class UndoBackgroundTask {
    private var identifier = UIBackgroundTaskIdentifier.invalid

    func begin() {
        identifier = UIApplication.shared.beginBackgroundTask { [self] in
            end()
        }
    }

    func end() {
        guard identifier != .invalid else { return }
        UIApplication.shared.endBackgroundTask(identifier)
        identifier = .invalid
    }
}
#endif
