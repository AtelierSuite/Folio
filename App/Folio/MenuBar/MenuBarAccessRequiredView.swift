#if os(macOS)
import SwiftUI

struct MenuBarAccessRequiredView: View {
    let onOpenApp: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label(String(localized: "Access.Title", table: "MenuBar"), systemImage: "calendar.badge.exclamationmark")
        } description: {
            Text(String(localized: "Access.Message", table: "MenuBar"))
        } actions: {
            Button(String(localized: "Header.OpenFolio", table: "MenuBar"), action: onOpenApp)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
#endif
