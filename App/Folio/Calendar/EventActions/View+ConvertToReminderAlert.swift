import Planner
import SwiftUI

extension View {
    /// Asks before converting, since a reminder has no end time to keep.
    func convertToReminderAlert(
        event: Binding<CalendarEvent?>,
        perform: @escaping (CalendarEvent) -> Void
    ) -> some View {
        alert(
            String(localized: "Convert.Title", table: "EventActions"),
            isPresented: Binding(get: { event.wrappedValue != nil }, set: { if !$0 { event.wrappedValue = nil } }),
            presenting: event.wrappedValue
        ) { presented in
            Button(String(localized: "Convert.Confirm", table: "EventActions")) {
                perform(presented)
            }
            Button(String(localized: "Cancel", table: "EventEditor"), role: .cancel) {}
        } message: { presented in
            Text(presented.isRecurring
                 ? String(localized: "Convert.Message.Series", table: "EventActions")
                 : String(localized: "Convert.Message", table: "EventActions"))
        }
    }
}
