import Planner
import SwiftUI

struct NoteEditorView: View {
    @Environment(NotesLibrary.self) private var library
    @Binding var text: String
    let noteURL: URL
    let focusesOnAppear: Bool

    var body: some View {
        MarkdownEditor(
            text: $text,
            baseURL: noteURL.deletingLastPathComponent(),
            focusesOnAppear: focusesOnAppear,
            imageAttacher: MarkdownImageAttacher { data, fileName in
                try await library.addAsset(data, named: fileName, for: noteURL)
            }
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
