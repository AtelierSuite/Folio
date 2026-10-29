import SwiftUI

struct NoteEditorView: View {
    @Binding var text: String

    var body: some View {
        TextEditor(text: $text)
            .font(.body.monospaced())
            .scrollContentBackground(.hidden)
            .contentMargins(.horizontal, 12, for: .scrollContent)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
