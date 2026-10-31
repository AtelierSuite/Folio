import Foundation

/// Keeps links and events in step: notes whose event was deleted are unlinked, and events whose linked note was
/// deleted lose the note's `folio://` URL.
@MainActor
public final class NoteLinkMaintenance {
    static let missingEventGrace: TimeInterval = 6 * 60 * 60

    private let library: NotesLibrary
    private let calendarStore: CalendarStore

    public init(library: NotesLibrary, calendarStore: CalendarStore) {
        self.library = library
        self.calendarStore = calendarStore
        library.onLinksRemoved = { [weak self] links in
            Task { await self?.removeNoteURLs(for: links) }
        }
    }

    /// An event only counts as deleted when the lookup can be trusted: full calendar access, its calendar still
    /// there, and no event with its identifiers for `missingEventGrace`, which also outlasts an undo of a delete.
    public func checkLinkedEvents(now: Date = .now) async {
        guard calendarStore.eventAuthorization.allowsReading, let location = library.indexLocation else { return }
        let prefix = "event:\(location)/"
        var missingKeys = Set<String>()
        for link in library.noteLinks.values {
            guard let reference = CalendarItemReference(storageKey: link.event.eventKey) else { continue }
            let key = prefix + link.event.eventKey
            switch await calendarStore.containsEvent(matching: reference) {
            case true?:
                continue
            case false? where calendarExists(for: link):
                missingKeys.insert(key)
                if now.timeIntervalSince(library.index.markMissing(key, at: now)) >= Self.missingEventGrace {
                    library.unlinkEvent(link.event.eventKey)
                }
            default:
                missingKeys.insert(key)
            }
        }
        library.index.clearMissing(withPrefix: prefix, except: missingKeys)
    }

    func removeNoteURLs(for links: [NoteLink]) async {
        for link in links {
            guard let reference = CalendarItemReference(storageKey: link.event.eventKey),
                  let day = DailyNoteNaming.date(forDayKey: link.event.dayKey),
                  let event = await calendarStore.event(matching: reference, on: day) else {
                continue
            }
            _ = try? await calendarStore.removeNoteLink(from: event)
        }
    }

    private func calendarExists(for link: NoteLink) -> Bool {
        calendarStore.eventCalendars.contains { $0.id == link.event.calendarIdentifier }
    }
}
