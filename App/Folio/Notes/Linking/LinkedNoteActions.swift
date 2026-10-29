import Planner
import SwiftUI

/// Opens the note linked to an event or a day, creating it first when there isn't one.
/// Shared by the event detail view, the day view and context menus.
@MainActor
struct LinkedNoteActions {
    let library: NotesLibrary
    let calendarStore: CalendarStore
    let router: AppRouter

    func openNote(for event: CalendarEvent) async throws {
        let isNew = library.linkedNote(for: event) == nil
        let url = try await library.createNote(for: event)
        if isNew, LinkedNoteSettings.writesLinkToEvent(), let link = library.deepLink(for: url) {
            _ = try? await calendarStore.addNoteLink(link, to: event)
        }
        router.open(.note(url))
    }

    func openDailyNote(on date: Date) async throws {
        let url = try await library.createDailyNote(on: date)
        router.open(.note(url))
    }
}
