import Foundation

enum MarkdownEditorMode: CaseIterable {
    case edit
    case preview

    var title: String {
        switch self {
        case .edit: String(localized: "Editor.Mode.Edit", table: "Markdown")
        case .preview: String(localized: "Editor.Mode.Preview", table: "Markdown")
        }
    }
}
