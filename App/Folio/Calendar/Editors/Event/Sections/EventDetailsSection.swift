import SwiftUI

struct EventDetailsSection: View {
    @Binding var urlText: String
    @Binding var notes: String

    var body: some View {
        Section {
            TextField(String(localized: "Field.URL", table: "EventEditor"), text: $urlText)
                .textContentType(.URL)
                #if os(iOS)
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
                #endif
                .autocorrectionDisabled()
            TextField(String(localized: "Field.Notes", table: "EventEditor"), text: $notes, axis: .vertical)
                .lineLimit(3...12)
        }
    }
}
