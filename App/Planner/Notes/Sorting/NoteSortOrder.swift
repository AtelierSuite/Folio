import Foundation

public enum NoteSortOrder: String, CaseIterable, Identifiable, Sendable {
    case dateModified
    case dateAdded

    public static let storageKey = "Notes.SortOrder"

    public var id: Self { self }

    public func date(of file: NoteFile) -> Date {
        switch self {
        case .dateModified: file.modifiedDate
        case .dateAdded: file.createdDate
        }
    }

    public func sorted(_ files: [NoteFile]) -> [NoteFile] {
        files.sorted { first, second in
            let firstDate = date(of: first)
            let secondDate = date(of: second)
            if firstDate == secondDate {
                return first.relativePath.localizedStandardCompare(second.relativePath) == .orderedAscending
            }
            return firstDate > secondDate
        }
    }
}
