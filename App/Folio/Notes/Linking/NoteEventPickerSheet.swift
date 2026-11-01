import Planner
import SwiftUI

struct NoteEventPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(NotesLibrary.self) private var library
    @Environment(CalendarStore.self) private var calendarStore
    let noteURL: URL
    @State private var date: Date
    @State private var events: [CalendarEvent]?

    init(noteURL: URL, initialDate: Date) {
        self.noteURL = noteURL
        _date = State(initialValue: initialDate)
    }

    var body: some View {
        NavigationStack {
            List {
                if !links.isEmpty {
                    Section(String(localized: "LinkEvent.Linked", table: "LinkedNotes")) {
                        NoteLinkedEventList(links: links) { link in
                            library.unlink(noteURL, fromEventKey: link.event.eventKey)
                        }
                    }
                }
                Section {
                    DatePicker(
                        String(localized: "LinkEvent.Date", table: "LinkedNotes"),
                        selection: $date,
                        displayedComponents: .date
                    )
                }
                Section(String(localized: "LinkEvent.Events", table: "LinkedNotes")) {
                    NoteEventPickerList(events: events, isLinked: isLinked, onSelect: toggleLink)
                }
            }
            .permissionGate(.calendar)
            .navigationTitle(String(localized: "LinkEvent.Title", table: "LinkedNotes"))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        dismiss()
                    }
                }
            }
            .task(id: EventQuery(
                day: Calendar.current.startOfDay(for: date),
                authorization: calendarStore.eventAuthorization
            )) {
                guard calendarStore.eventAuthorization.allowsReading,
                      let day = Calendar.current.dateInterval(of: .day, for: date) else {
                    events = []
                    return
                }
                events = await calendarStore.events(in: day).sorted { $0.startDate < $1.startDate }
            }
        }
        #if os(macOS)
        .frame(minWidth: 420, minHeight: 480)
        #endif
    }

    private struct EventQuery: Equatable {
        let day: Date
        let authorization: CalendarAuthorizationStatus
    }

    private var links: [NoteLink] {
        library.eventLinks(forNote: noteURL).sorted { ($0.event.dayKey, $0.linkedAt) < ($1.event.dayKey, $1.linkedAt) }
    }

    private func isLinked(_ event: CalendarEvent) -> Bool {
        library.eventLink(forNote: noteURL, to: event) != nil
    }

    private func toggleLink(_ event: CalendarEvent) {
        if let link = library.eventLink(forNote: noteURL, to: event) {
            library.unlink(noteURL, fromEventKey: link.event.eventKey)
            return
        }
        library.link(noteURL, to: event)
        if LinkedNoteSettings.writesLinkToEvent(), let deepLink = library.deepLink(for: noteURL) {
            Task {
                _ = try? await calendarStore.addNoteLink(deepLink, to: event)
            }
        }
    }
}
