import Foundation
import SwiftData

/// What this device last read from a note, so unchanged notes are never read again. Kept on the device only.
@Model
final class NoteFileRecord {
    var location: String = ""
    var relativePath: String = ""
    var isTrashed = false
    var modifiedDate = Date.distantPast
    var referencedNames: [String] = []

    init(location: String, relativePath: String, isTrashed: Bool, modifiedDate: Date, referencedNames: [String]) {
        self.location = location
        self.relativePath = relativePath
        self.isTrashed = isTrashed
        self.modifiedDate = modifiedDate
        self.referencedNames = referencedNames
    }
}
