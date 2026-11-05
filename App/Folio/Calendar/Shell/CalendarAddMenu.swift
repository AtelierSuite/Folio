import Planner
import SwiftUI

struct CalendarAddMenu: View {
    @Environment(\.platformCapabilities) private var capabilities
    @Environment(CalendarNavigation.self) private var navigation
    @Environment(NotesLibrary.self) private var library
    @Environment(CalendarStore.self) private var calendarStore
    @Environment(AppRouter.self) private var router
    @Binding var composer: CalendarComposer?
    @State private var errorMessage: String?

    var body: some View {
        Menu(String(localized: "Toolbar.Add", table: "Calendar"), systemImage: "plus") {
            Button(String(localized: "Add.Event", table: "Calendar"), systemImage: "calendar.badge.plus") {
                composer = .newEvent
            }
            Button(String(localized: "Add.Reminder", table: "Calendar"), systemImage: "checklist") {
                composer = .newReminder
            }
            if capabilities.supports(.alarms) {
                Button(String(localized: "Add.Alarm", table: "StandaloneAlarms"), systemImage: "alarm") {
                    composer = .newAlarm
                }
                .accessibilityIdentifier("AddMenu.Alarm")
            }
            if library.store != nil {
                Section {
                    Button(dailyNoteTitle, systemImage: "note.text") {
                        Task { await openDailyNote() }
                    }
                }
            }
        }
        .notesErrorAlert(message: $errorMessage)
    }

    private var dailyNoteTitle: String {
        library.dailyNote(on: navigation.selectedDate) == nil
            ? String(localized: "Daily.Create", table: "LinkedNotes")
            : String(localized: "Daily.OpenNote", table: "LinkedNotes")
    }

    private func openDailyNote() async {
        do {
            try await LinkedNoteActions(library: library, calendarStore: calendarStore, router: router)
                .openDailyNote(on: navigation.selectedDate)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
