import Foundation

public enum NotesLibraryStatus: Hashable, Sendable {
    case loading
    case ready
    case iCloudUnavailable
    case folderUnavailable
}
