import SwiftUI

struct EventEditorView: View {
    let initialDate: Date

    var body: some View {
        ContentUnavailableView(String(localized: "Add.Event", table: "Calendar"), systemImage: "calendar.badge.plus")
    }
}
