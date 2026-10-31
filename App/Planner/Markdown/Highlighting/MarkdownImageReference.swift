import Foundation

/// An `![alt](source)` image outside code, located by UTF-16 range so an editor can swap it for an attachment.
public struct MarkdownImageReference: Hashable, Sendable {
    public let range: NSRange
    public let altText: String
    public let source: String

    private static let pattern = MarkdownHighlighter.expression(#"!\[([^\]\n]*)\]\(([^)\s]+)(?:[ \t]+"[^"\n]*")?\)"#)

    public static func references(in text: String) -> [MarkdownImageReference] {
        let nsText = text as NSString
        let codeRanges = MarkdownHighlighter.highlights(in: text)
            .filter { $0.kind == .codeBlock || $0.kind == .inlineCode || $0.kind == .frontMatter }
            .map(\.range)
        return pattern.matches(in: text, range: NSRange(location: 0, length: nsText.length)).compactMap { match in
            guard !codeRanges.contains(where: { NSIntersectionRange($0, match.range).length > 0 }) else {
                return nil
            }
            return MarkdownImageReference(
                range: match.range,
                altText: nsText.substring(with: match.range(at: 1)),
                source: nsText.substring(with: match.range(at: 2))
            )
        }
    }

    public var markdown: String {
        "![\(altText)](\(source))"
    }
}
