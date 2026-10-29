import SwiftUI

struct ReminderEditorView: View {
    let initialDate: Date

    var body: some View {
        ContentUnavailableView(String(localized: "Add.Reminder", table: "Calendar"), systemImage: "checklist")
    }
}
