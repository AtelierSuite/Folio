import Foundation

/// Every file name a note could be pointing at, percent-decoded and lowercased: link targets, `![[wiki embeds]]`,
/// HTML `src` attributes and any other token that looks like a file name. It deliberately finds more than it
/// needs, so cleanup never removes a file a note uses.
public enum MarkdownFileNames {
    private static let fileToken = MarkdownHighlighter.expression(#"[^/\\\s()\[\]|"'<>=]+\.[A-Za-z0-9]{2,5}"#)
    private static let linkTarget = MarkdownHighlighter.expression(
        #"\]\(<?([^)>\n]+?)>?(?:\s+"[^"\n]*")?\)|\[\[([^\]|#\n]+)|src\s*=\s*["']([^"'\n]+)["']"#
    )

    public static func names(in text: String) -> Set<String> {
        var names = Set<String>()
        let source = text as NSString
        for match in linkTarget.matches(in: text, range: NSRange(location: 0, length: source.length)) {
            for group in 1...3 where match.range(at: group).location != NSNotFound {
                let target = source.substring(with: match.range(at: group))
                let decoded = target.removingPercentEncoding ?? target
                if let name = decoded.split(separator: "/").last {
                    names.insert(name.trimmingCharacters(in: .whitespaces).lowercased())
                }
            }
        }
        for candidate in [text, text.removingPercentEncoding ?? text] {
            let nsCandidate = candidate as NSString
            for match in fileToken.matches(in: candidate, range: NSRange(location: 0, length: nsCandidate.length)) {
                names.insert(nsCandidate.substring(with: match.range).lowercased())
            }
        }
        return names
    }
}
