import Foundation

public enum NoteSaveResult: Hashable, Sendable {
    case saved(Note)
    case conflict(current: Note, conflictedCopyURL: URL)
}
