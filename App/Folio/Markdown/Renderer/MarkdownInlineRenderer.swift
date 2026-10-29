import Planner
import SwiftUI

struct MarkdownInlineRenderer {
    let baseURL: URL?

    func attributedString(from inlines: [MarkdownInline], intent: InlinePresentationIntent = []) -> AttributedString {
        inlines.reduce(into: AttributedString()) { result, inline in
            result += attributedString(from: inline, intent: intent)
        }
    }

    private func attributedString(from inline: MarkdownInline, intent: InlinePresentationIntent) -> AttributedString {
        switch inline {
        case .text(let text), .html(let text):
            return styled(text, intent: intent)
        case .emphasis(let children):
            return attributedString(from: children, intent: intent.union(.emphasized))
        case .strong(let children):
            return attributedString(from: children, intent: intent.union(.stronglyEmphasized))
        case .strikethrough(let children):
            return attributedString(from: children, intent: intent.union(.strikethrough))
        case .code(let code):
            var string = styled(code, intent: intent.union(.code))
            string.backgroundColor = Color.secondary.opacity(0.15)
            return string
        case .link(let destination, let content):
            var string = attributedString(from: content, intent: intent)
            string.link = destination.flatMap { MarkdownURLResolver.url(for: $0, relativeTo: baseURL) }
            return string
        case .image(let image):
            return styled(image.altText, intent: intent.union(.emphasized))
        case .softBreak:
            return styled(" ", intent: intent)
        case .lineBreak:
            return styled("\n", intent: intent)
        }
    }

    private func styled(_ text: String, intent: InlinePresentationIntent) -> AttributedString {
        var string = AttributedString(text)
        if !intent.isEmpty {
            string.inlinePresentationIntent = intent
        }
        return string
    }
}
