import Foundation

extension SearchIndex {
    /// An empty query text only returns results when a filter narrows them down.
    func search(_ query: SearchQuery) -> [SearchDocument] {
        let terms = SearchTokenizer.terms(in: query.text)
        let candidates: [SearchDocument]
        if terms.isEmpty {
            guard query.hasNarrowingFilter else { return [] }
            candidates = Array(documents.values)
        } else {
            candidates = matchingDocumentIDs(for: terms).compactMap { documents[$0] }
        }
        return candidates.filter(query.matches).sorted(by: SearchDocument.chronologically)
    }

    private func matchingDocumentIDs(for terms: [String]) -> Set<String> {
        var result: Set<String>?
        for term in terms {
            let matches = documentIDs(matching: term)
            result = result.map { $0.intersection(matches) } ?? matches
            if result?.isEmpty == true { break }
        }
        return result ?? []
    }
}
