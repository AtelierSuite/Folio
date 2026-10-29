import Foundation

enum YAMLScalar {
    static func value(of text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        if let quote = trimmed.first, quote == "\"" || quote == "'",
           let closing = trimmed.dropFirst().lastIndex(of: quote) {
            let inner = String(trimmed[trimmed.index(after: trimmed.startIndex)..<closing])
            return quote == "\"" ? unescaped(inner) : inner.replacingOccurrences(of: "''", with: "'")
        }
        return withoutComment(trimmed)
    }

    static func formatted(_ value: String) -> String {
        needsQuotes(value) ? "\"\(escaped(value))\"" : value
    }

    private static func withoutComment(_ text: String) -> String {
        if text.hasPrefix("#") { return "" }
        guard let range = text.range(of: " #") else { return text }
        return text[..<range.lowerBound].trimmingCharacters(in: .whitespaces)
    }

    private static func needsQuotes(_ value: String) -> Bool {
        let reservedWords: Set = ["true", "false", "yes", "no", "on", "off", "null", "~"]
        let specialCharacters = CharacterSet(charactersIn: ":#,[]{}&*!|>'\"%@`\\")
        return value.isEmpty
            || value.trimmingCharacters(in: .whitespaces) != value
            || value.rangeOfCharacter(from: specialCharacters) != nil
            || value.rangeOfCharacter(from: .newlines) != nil
            || value.hasPrefix("-") || value.hasPrefix("?")
            || reservedWords.contains(value.lowercased())
            || Double(value) != nil
    }

    private static func escaped(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
    }

    private static func unescaped(_ value: String) -> String {
        var result = ""
        var isEscaping = false
        for character in value {
            if isEscaping {
                result.append(character == "n" ? "\n" : character == "t" ? "\t" : character)
                isEscaping = false
            } else if character == "\\" {
                isEscaping = true
            } else {
                result.append(character)
            }
        }
        return result
    }
}
