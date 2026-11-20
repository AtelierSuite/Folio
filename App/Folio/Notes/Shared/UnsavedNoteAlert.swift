import SwiftUI

struct UnsavedNoteDestination: Equatable {
    let url: URL?
}

extension View {
    func unsavedNoteAlert(
        destination: Binding<UnsavedNoteDestination?>,
        onDiscard: @escaping (UnsavedNoteDestination) -> Void
    ) -> some View {
        alert(
            String(localized: "UnsavedChanges.Title", table: "Notes"),
            isPresented: Binding(
                get: { destination.wrappedValue != nil },
                set: { isPresented in
                    if !isPresented {
                        destination.wrappedValue = nil
                    }
                }
            ),
            presenting: destination.wrappedValue
        ) { pendingDestination in
            Button(String(localized: "UnsavedChanges.KeepEditing", table: "Notes"), role: .cancel) {}
            Button(String(localized: "UnsavedChanges.Discard", table: "Notes"), role: .destructive) {
                onDiscard(pendingDestination)
            }
        } message: { _ in
            Text(String(localized: "UnsavedChanges.Message", table: "Notes"))
        }
    }
}
