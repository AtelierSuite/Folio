import Planner
import SwiftUI

struct NoteEventPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(NotesLibrary.self) private var library
    @Environment(CalendarStore.self) private var calendarStore
    @Binding var text: String
    let noteURL: URL
    @State private var date: Date
    @State private var events: [CalendarEvent]?

    init(text: Binding<String>, noteURL: URL) {
        _text = text
        self.noteURL = noteURL
        _date = State(initialValue: MarkdownNoteFile(contents: text.wrappedValue).frontMatter.date ?? .now)
    }

    var body: some View {
        NavigationStack {
            List {
                if linkedKey != nil {
                    Section {
                        Button(String(localized: "LinkEvent.Remove", table: "LinkedNotes"), role: .destructive) {
                            text = NoteEventLink.unlinking(text)
                            dismiss()
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
                    NoteEventPickerList(events: events, linkedKey: linkedKey, onSelect: link)
                }
            }
            .permissionGate(.calendar)
            .navigationTitle(String(localized: "LinkEvent.Title", table: "LinkedNotes"))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
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

    private var linkedKey: String? {
        NoteEventLink.eventKey(in: text)
    }

    private func link(_ event: CalendarEvent) {
        text = NoteEventLink.linking(text, to: event)
        if LinkedNoteSettings.writesLinkToEvent(), let deepLink = library.deepLink(for: noteURL) {
            Task {
                _ = try? await calendarStore.addNoteLink(deepLink, to: event)
            }
        }
        dismiss()
    }
}
