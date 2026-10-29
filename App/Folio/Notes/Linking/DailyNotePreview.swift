import Planner
import SwiftUI

struct DailyNotePreview: View {
    let note: LinkedNote
    let onOpen: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "note.text")
                .foregroundStyle(.tint)
            VStack(alignment: .leading, spacing: 2) {
                Text(String(localized: "Daily.Title", table: "LinkedNotes"))
                    .font(.subheadline.weight(.semibold))
                Text(previewText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Button(String(localized: "Daily.Open", table: "LinkedNotes"), action: onOpen)
                .buttonStyle(.bordered)
                .controlSize(.small)
                .accessibilityIdentifier("DailyNote.Open")
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onOpen)
    }

    private var previewText: String {
        let preview = note.preview.replacingOccurrences(of: "\n", with: " ")
        return preview.isEmpty ? String(localized: "Daily.EmptyPreview", table: "LinkedNotes") : preview
    }
}
