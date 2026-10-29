import Foundation

public enum NotesStorageError: Error, Hashable, Sendable {
    case iCloudUnavailable
    case folderNotChosen
    case folderAccessDenied
    case downloadTimedOut
    case invalidTitle
    case notInTrash
    case unreadableText
}
