import Foundation

/// An in-memory inverted index. Every word of a document maps to the documents containing it, and a
/// sorted word list answers prefix lookups with a binary search.
struct SearchIndex: Sendable {
    private(set) var documents: [String: SearchDocument] = [:]
    private var postings: [String: Set<String>] = [:]
    private var tokensByDocument: [String: Set<String>] = [:]
    private(set) var sortedTokens: [String] = []

    var count: Int { documents.count }

    func document(withID id: String) -> SearchDocument? {
        documents[id]
    }

    func documentIDs(of kind: SearchItemKind) -> Set<String> {
        Set(documents.values.lazy.filter { $0.kind == kind }.map(\.id))
    }

    /// Adds, replaces and removes documents, skipping any that did not change.
    mutating func apply(upserting newDocuments: [SearchDocument], removing removedIDs: some Sequence<String>) {
        var vocabularyChanged = false
        for id in removedIDs {
            vocabularyChanged = removeDocument(withID: id) || vocabularyChanged
        }
        for document in newDocuments where documents[document.id] != document {
            vocabularyChanged = removeDocument(withID: document.id) || vocabularyChanged
            vocabularyChanged = insert(document) || vocabularyChanged
        }
        if vocabularyChanged {
            sortedTokens = postings.keys.sorted()
        }
    }

    private mutating func insert(_ document: SearchDocument) -> Bool {
        let tokens = SearchTokenizer.tokens(in: document.searchableText)
        documents[document.id] = document
        tokensByDocument[document.id] = tokens
        var addedToken = false
        for token in tokens {
            if postings[token, default: []].insert(document.id).inserted, postings[token]?.count == 1 {
                addedToken = true
            }
        }
        return addedToken
    }

    private mutating func removeDocument(withID id: String) -> Bool {
        guard documents.removeValue(forKey: id) != nil else { return false }
        var removedToken = false
        for token in tokensByDocument.removeValue(forKey: id) ?? [] {
            postings[token]?.remove(id)
            if postings[token]?.isEmpty == true {
                postings[token] = nil
                removedToken = true
            }
        }
        return removedToken
    }

    func documentIDs(matching term: String) -> Set<String> {
        var matches = Set<String>()
        for token in tokens(matching: term) {
            matches.formUnion(postings[token] ?? [])
        }
        return matches
    }

    private func tokens(matching term: String) -> some Sequence<String> {
        if SearchTokenizer.matchesInsideWords(term) {
            return AnySequence(sortedTokens.lazy.filter { $0.contains(term) })
        }
        let start = firstIndex(notBefore: term)
        return AnySequence(sortedTokens[start...].lazy.prefix { $0.hasPrefix(term) })
    }

    private func firstIndex(notBefore term: String) -> Int {
        var low = 0
        var high = sortedTokens.count
        while low < high {
            let middle = (low + high) / 2
            if sortedTokens[middle] < term {
                low = middle + 1
            } else {
                high = middle
            }
        }
        return low
    }
}
