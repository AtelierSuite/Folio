import Foundation

public enum NotesStorageMode: String, Sendable, CaseIterable, Identifiable {
    case iCloudDrive
    case onMyDevice
    case customFolder

    public var id: String { rawValue }

    public var keepsSourceAfterMigration: Bool {
        self != .onMyDevice
    }
}
