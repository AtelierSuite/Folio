import Foundation

/// Front matter links of every note in the library, kept in memory so finding an event's note or a
/// day's note never reads files. `updated(with:in:)` only re-reads notes that changed.
public struct LinkedNoteIndex: Sendable, Equatable {
    public private(set) var notes: [URL: LinkedNote] = [:]

    public init(notes: [LinkedNote] = []) {
        self.notes = Dictionary(notes.map { ($0.url, $0) }, uniquingKeysWith: { _, last in last })
    }

    public mutating func insert(_ note: LinkedNote) {
        notes[note.url] = note
    }

    public func note(linkedTo reference: CalendarItemReference) -> LinkedNote? {
        let linkedNotes = notes.values.filter { $0.eventKey != nil }
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

    /// Prefers the note at `Daily/yyyy-MM-dd.md`, then the newest note dated that day that isn't
    /// linked to an event.
    public func dailyNote(on date: Date, timeZone: TimeZone = .current) -> LinkedNote? {
        let dayKey = DailyNoteNaming.dayKey(for: date, timeZone: timeZone)
        let namedNotes = notes.values.filter { DailyNoteNaming.dayKey(ofRelativePath: $0.file.relativePath) == dayKey }
        if let named = Self.newest(namedNotes) {
            return named
        }
        return Self.newest(notes.values.filter { $0.eventKey == nil && $0.dayKey == dayKey })
    }

    private static func newest(_ notes: some Sequence<LinkedNote>) -> LinkedNote? {
        notes.max { first, second in
            first.file.modifiedDate == second.file.modifiedDate
                ? first.file.relativePath > second.file.relativePath
                : first.file.modifiedDate < second.file.modifiedDate
        }
    }
}
