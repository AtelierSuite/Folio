import Planner
import SwiftUI

struct NoteShareLink: View {
    let title: String
    let text: String

    var body: some View {
        ShareLink(
            item: MarkdownNoteFile.shareableMarkdown(from: text),
            subject: Text(title),
            preview: SharePreview(title)
        ) {
            Label(String(localized: "Action.Share", table: "Notes"), systemImage: "square.and.arrow.up")
        }
    }
}
