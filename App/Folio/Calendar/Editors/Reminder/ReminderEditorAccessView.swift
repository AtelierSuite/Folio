import Planner
import SwiftUI

struct ReminderEditorAccessView: View {
    @Environment(CalendarStore.self) private var store

    var body: some View {
        ContentUnavailableView {
            Label(String(localized: "Access.Title", table: "ReminderEditor"), systemImage: "checklist")
        } description: {
            Text(String(localized: "Access.Description", table: "ReminderEditor"))
        } actions: {
            Button(String(localized: "Access.Allow", table: "ReminderEditor")) {
                Task { _ = try? await store.requestFullAccessToReminders() }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
