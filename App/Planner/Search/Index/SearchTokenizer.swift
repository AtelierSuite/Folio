import Foundation

enum SearchTokenizer {
    static func normalized(_ text: String) -> String {
        text.folding(options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive], locale: nil)
    }

    static func tokens(in text: String) -> Set<String> {
        var tokens = Set<String>()
        var current = String.UnicodeScalarView()
        for scalar in normalized(text).unicodeScalars {
            if CharacterSet.alphanumerics.contains(scalar) {
                current.append(scalar)
            } else if !current.isEmpty {
                tokens.insert(String(current))
                current.removeAll(keepingCapacity: true)
            }
        }
        if !current.isEmpty {
            tokens.insert(String(current))
        }
        return tokens
    }

    static func terms(in query: String) -> [String] {
        tokens(in: query).sorted()
    }

    /// Scripts written without spaces (Chinese, Japanese, Korean) end up as long runs in one token,
    /// so their terms match anywhere inside a token instead of only at the start.
    static func matchesInsideWords(_ term: String) -> Bool {
        term.unicodeScalars.contains { scalar in
            scalar.value >= 0x2E80 && scalar.properties.isAlphabetic
        }
    }
}
