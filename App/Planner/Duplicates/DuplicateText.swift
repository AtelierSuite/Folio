import Foundation

enum DuplicateText {
    static let minimumSimilarity = 0.95

    private static let forwardingPrefixes = ["fwd:", "fw:", "re:"]

    /// Word order and punctuation are ignored, so "Team – Sync" and "sync team" share a key.
    /// Diacritics stay significant because folding them would merge different Japanese words (か and が).
    static func comparisonKey(_ text: String) -> String? {
        let folded = removingForwardingPrefixes(from: folded(text))
        let words = folded.components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty }
        let key = words.isEmpty ? folded : words.sorted().joined(separator: " ")
        return key.isEmpty ? nil : key
    }

    static func isSimilar(_ first: String, _ second: String) -> Bool {
        first == second || similarity(between: first, and: second) >= minimumSimilarity
    }

    static func similarity(between first: String, and second: String) -> Double {
        let firstCharacters = Array(first)
        let secondCharacters = Array(second)
        let longest = max(firstCharacters.count, secondCharacters.count)
        guard longest > 0 else { return 1 }
        return 1 - Double(editDistance(firstCharacters, secondCharacters)) / Double(longest)
    }

    private static func editDistance(_ first: [Character], _ second: [Character]) -> Int {
        var previousRow = Array(0...second.count)
        for (firstIndex, firstCharacter) in first.enumerated() {
            var currentRow = [firstIndex + 1]
            for (secondIndex, secondCharacter) in second.enumerated() {
                let substitution = previousRow[secondIndex] + (firstCharacter == secondCharacter ? 0 : 1)
                currentRow.append(min(substitution, previousRow[secondIndex + 1] + 1, currentRow[secondIndex] + 1))
            }
            previousRow = currentRow
        }
        return previousRow[second.count]
    }

    private static func folded(_ text: String) -> String {
        text.precomposedStringWithCanonicalMapping
            .folding(options: [.caseInsensitive, .widthInsensitive], locale: nil)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func removingForwardingPrefixes(from text: String) -> String {
        var remaining = text
        while let prefix = forwardingPrefixes.first(where: remaining.hasPrefix) {
            remaining = remaining.dropFirst(prefix.count).trimmingCharacters(in: .whitespaces)
        }
        return remaining
    }
}
