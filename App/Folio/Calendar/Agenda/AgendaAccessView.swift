import Planner
import SwiftUI

struct AgendaAccessView: View {
    @Environment(CalendarStore.self) private var store

    var body: some View {
        ContentUnavailableView {
            Label(String(localized: "Access.Title", table: "Agenda"), systemImage: "calendar.badge.exclamationmark")
        } description: {
            Text(String(localized: "Access.Description", table: "Agenda"))
        } actions: {
            Button(String(localized: "Access.Allow", table: "Agenda")) {
                Task {
                    _ = try? await store.requestFullAccessToEvents()
                    _ = try? await store.requestFullAccessToReminders()
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
