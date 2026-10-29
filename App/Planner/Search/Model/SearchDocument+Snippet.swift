import Foundation

extension SearchDocument {
    /// A single line of the body around the first query term, or the start of the body when no term is found.
    public func snippet(matching queryText: String, length: Int = 120) -> String? {
        let text = body.replacing(/\s+/, with: " ").trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return nil }
        let match = SearchTokenizer.terms(in: queryText).lazy.compactMap { term in
            text.range(of: term, options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive])
        }.first
        guard let match else {
            return String(text.prefix(length))
        }
        let leadingContext = length / 4
        let start = text.index(match.lowerBound, offsetBy: -leadingContext, limitedBy: text.startIndex)
            ?? text.startIndex
        let end = text.index(start, offsetBy: length, limitedBy: text.endIndex) ?? text.endIndex
        let excerpt = String(text[start..<end])
        return (start > text.startIndex ? "…" : "") + excerpt + (end < text.endIndex ? "…" : "")
    }
}
