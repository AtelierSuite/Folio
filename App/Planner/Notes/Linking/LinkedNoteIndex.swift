import Foundation

/// The links of every note in the library, one entry per note and event, kept in memory so finding an event's
/// note or a day's note never reads files.
public struct LinkedNoteIndex: Sendable, Equatable {
    public private(set) var notes: Set<LinkedNote> = []

    public init(notes: [LinkedNote] = []) {
        self.notes = Set(notes)
    }

    public mutating func insert(_ note: LinkedNote) {
        notes.insert(note)
    }

    public func note(linkedTo reference: CalendarItemReference) -> LinkedNote? {
        let linkedNotes = notes.filter { $0.eventKey != nil }
        if let exact = Self.newest(linkedNotes.filter { $0.eventKey == reference.storageKey }) {
            return exact
        }
        let candidates = linkedNotes.compactMap { note in
            note.eventKey.flatMap(CalendarItemReference.init(storageKey:)).map { ($0, note) }
        }
        guard let match = reference.bestMatch(in: candidates.map(\.0)) else {
            return nil
        }
        return Self.newest(candidates.filter { $0.0 == match }.map(\.1))
    }

    /// The note at `Daily/yyyy-MM-dd.md`.
    public func dailyNote(on date: Date, timeZone: TimeZone = .current) -> LinkedNote? {
        let dayKey = DailyNoteNaming.dayKey(for: date, timeZone: timeZone)
        return Self.newest(notes.filter {
            DailyNoteNaming.dayKey(ofRelativePath: $0.file.relativePath) == dayKey
        })
    }

    private static func newest(_ notes: some Sequence<LinkedNote>) -> LinkedNote? {
        notes.max { first, second in
            first.file.modifiedDate == second.file.modifiedDate
                ? first.file.relativePath > second.file.relativePath
                : first.file.modifiedDate < second.file.modifiedDate
        }
    }
}
