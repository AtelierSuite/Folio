import Foundation

public struct NotesStorageSettings: @unchecked Sendable {
    static let modeKey = "Notes.StorageMode"
    static let folderBookmarkKey = "Notes.FolderBookmark"

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = AppGroup.userDefaults) {
        self.defaults = defaults
    }

    public var mode: NotesStorageMode? {
        get { defaults.string(forKey: Self.modeKey).flatMap(NotesStorageMode.init(rawValue:)) }
        nonmutating set { defaults.set(newValue?.rawValue, forKey: Self.modeKey) }
    }

    public var folderBookmark: Data? {
        get { defaults.data(forKey: Self.folderBookmarkKey) }
        nonmutating set { defaults.set(newValue, forKey: Self.folderBookmarkKey) }
    }
}
