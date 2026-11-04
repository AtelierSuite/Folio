import Foundation

enum DuplicateText {
    private static let forwardingPrefixes = ["fwd:", "fw:", "re:"]

    /// Diacritics stay significant because folding them would merge different Japanese words (か and が).
    static func folded(_ text: String) -> String {
        text.precomposedStringWithCanonicalMapping
            .folding(options: [.caseInsensitive, .widthInsensitive], locale: nil)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Word order and punctuation are ignored, so "Team – Sync" and "sync team" share a key.
    static func titleKey(_ title: String) -> String? {
        let text = removingForwardingPrefixes(from: folded(title))
        let words = text.components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty }
        let key = words.isEmpty ? text : words.sorted().joined(separator: " ")
        return key.isEmpty ? nil : key
    }

    private static func removingForwardingPrefixes(from text: String) -> String {
        var remaining = text
        while let prefix = forwardingPrefixes.first(where: remaining.hasPrefix) {
            remaining = remaining.dropFirst(prefix.count).trimmingCharacters(in: .whitespaces)
        }
        return remaining
    }
}
