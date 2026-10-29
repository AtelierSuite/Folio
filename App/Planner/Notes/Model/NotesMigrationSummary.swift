import Foundation

public struct NotesMigrationSummary: Hashable, Sendable {
    public var copiedFileCount = 0
    public var skippedDuplicateCount = 0
    public var renamedFileCount = 0

    public init() {}
}
