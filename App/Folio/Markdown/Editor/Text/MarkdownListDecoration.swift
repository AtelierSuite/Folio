import Foundation

/// A bullet, checkbox or rule drawn over Markdown whose text is concealed.
struct MarkdownListDecoration: Equatable {
    enum Kind: Equatable {
        case bullet
        case task(isChecked: Bool)
        case rule
    }

    let kind: Kind
    let range: NSRange
}
