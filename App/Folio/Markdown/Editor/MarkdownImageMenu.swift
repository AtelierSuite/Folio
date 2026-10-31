import SwiftUI

struct MarkdownImageMenu: View {
    let onPickPhoto: () -> Void
    let onPickFile: () -> Void

    var body: some View {
        Menu {
            Button(
                String(localized: "Image.PhotoLibrary", table: "Markdown"),
                systemImage: "photo.on.rectangle",
                action: onPickPhoto
            )
            Button(String(localized: "Image.ChooseFile", table: "Markdown"), systemImage: "folder", action: onPickFile)
        } label: {
            MarkdownFormattingBarIcon(
                title: String(localized: "Format.AttachImage", table: "Markdown"),
                systemImage: "photo.badge.plus"
            )
        }
        .menuIndicator(.hidden)
        .buttonStyle(.plain)
        .help(String(localized: "Format.AttachImage", table: "Markdown"))
    }
}
