import SwiftUI

struct CalendarAddMenu: View {
    @Binding var composer: CalendarComposer?

    var body: some View {
        Menu(String(localized: "Toolbar.Add", table: "Calendar"), systemImage: "plus") {
            Button(String(localized: "Add.Event", table: "Calendar"), systemImage: "calendar.badge.plus") {
                composer = .newEvent
            }
            Button(String(localized: "Add.Reminder", table: "Calendar"), systemImage: "checklist") {
                composer = .newReminder
            }
        }
    }
}
