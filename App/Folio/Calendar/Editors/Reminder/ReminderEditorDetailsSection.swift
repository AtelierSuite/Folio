import Planner
import SwiftUI

struct ReminderEditorDetailsSection: View {
    @Binding var draft: ReminderDraft
    @Binding var urlText: String
    let focusesTitle: Bool
    @FocusState private var isTitleFocused: Bool

    var body: some View {
        Section {
            TextField(String(localized: "Field.Title", table: "ReminderEditor"), text: $draft.title)
                .focused($isTitleFocused)
                .onAppear { isTitleFocused = focusesTitle }
            TextField(String(localized: "Field.Notes", table: "ReminderEditor"), text: $draft.notes, axis: .vertical)
                .lineLimit(2...8)
            TextField(String(localized: "Field.URL", table: "ReminderEditor"), text: $urlText)
                .autocorrectionDisabled()
                #if os(iOS)
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
                #endif
        }
    }
}
