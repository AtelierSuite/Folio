import SwiftUI

struct NoteEditorView: View {
    @Binding var text: String

    var body: some View {
        TextEditor(text: $text)
            .font(.body.monospaced())
            .scrollContentBackground(.hidden)
            .padding(.horizontal)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
