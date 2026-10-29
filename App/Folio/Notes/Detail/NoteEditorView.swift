import SwiftUI

struct NoteEditorView: View {
    @Binding var text: String
    let noteURL: URL

    var body: some View {
        MarkdownEditor(text: $text, baseURL: noteURL.deletingLastPathComponent())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
