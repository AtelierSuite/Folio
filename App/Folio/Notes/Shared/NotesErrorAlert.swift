import SwiftUI

extension View {
    func notesErrorAlert(message: Binding<String?>) -> some View {
        alert(
            String(localized: "Error.Title", table: "Notes"),
            isPresented: Binding(
                get: { message.wrappedValue != nil },
                set: { isPresented in
                    if !isPresented {
                        message.wrappedValue = nil
                    }
                }
            )
        ) {
            Button(String(localized: "Action.OK", table: "Notes")) {}
        } message: {
            Text(message.wrappedValue ?? "")
        }
    }
}
