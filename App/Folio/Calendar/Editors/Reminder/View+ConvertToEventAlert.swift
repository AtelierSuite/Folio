import SwiftUI

extension View {
    /// Asks before converting, since the event's end time is made up and some reminder details are lost.
    func convertToEventAlert(isPresented: Binding<Bool>, perform: @escaping () -> Void) -> some View {
        alert(String(localized: "Convert.Title", table: "ReminderEditor"), isPresented: isPresented) {
            Button(String(localized: "Convert.Confirm", table: "ReminderEditor"), action: perform)
            Button(String(localized: "Action.Cancel", table: "ReminderEditor"), role: .cancel) {}
        } message: {
            Text(String(localized: "Convert.Message", table: "ReminderEditor"))
        }
    }
}
