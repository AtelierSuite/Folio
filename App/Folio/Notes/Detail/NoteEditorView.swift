import Planner
import SwiftUI

struct NoteEditorView: View {
    @Binding var text: String
    let noteURL: URL
    let focusesOnAppear: Bool

    var body: some View {
        MarkdownEditor(
            text: $text,
            baseURL: noteURL.deletingLastPathComponent(),
            focusesOnAppear: focusesOnAppear
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
