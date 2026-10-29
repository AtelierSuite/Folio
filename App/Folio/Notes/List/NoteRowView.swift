import Planner
import SwiftUI

struct NoteRowView: View {
    let file: NoteFile

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(file.title)
                    .lineLimit(1)
                HStack(spacing: 6) {
                    Text(file.modifiedDate, format: .relative(presentation: .named))
                    if !file.folderPath.isEmpty {
                        Label(file.folderPath, systemImage: "folder")
                            .labelStyle(.titleAndIcon)
                            .lineLimit(1)
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            if !file.isDownloaded {
                Image(systemName: "icloud.and.arrow.down")
                    .foregroundStyle(.secondary)
                    .accessibilityLabel(String(localized: "Row.NotDownloaded", table: "Notes"))
            }
        }
    }
}
