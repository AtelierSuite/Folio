import Foundation
import SwiftData

/// Something that looked gone, such as a note, an event or an unused image, remembered with when it was first
/// missed so it is only removed once it has stayed gone. Kept on the device only.
@Model
final class NoteRemovalCandidate {
    var key: String = ""
    var missingSince = Date.distantPast

    init(key: String, missingSince: Date) {
        self.key = key
        self.missingSince = missingSince
    }
}
