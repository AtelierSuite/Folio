import Foundation

enum YAMLSequence {
    static func values(of lines: [String]) -> [String] {
        guard let firstLine = lines.first, let colon = firstLine.firstIndex(of: ":") else { return [] }
        let inlineValue = firstLine[firstLine.index(after: colon)...].trimmingCharacters(in: .whitespaces)
        if inlineValue.hasPrefix("[") {
            return flowValues(of: inlineValue)
        }
        if !inlineValue.isEmpty, !inlineValue.hasPrefix("#") {
            return YAMLScalar.value(of: inlineValue)
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
        }
        return lines.dropFirst().compactMap { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.hasPrefix("-") else { return nil }
            let value = YAMLScalar.value(of: String(trimmed.dropFirst()))
            return value.isEmpty ? nil : value
        }
    }

    static func formatted(_ values: [String]) -> String {
        "[" + values.map(YAMLScalar.formatted).joined(separator: ", ") + "]"
    }

    private static func flowValues(of text: String) -> [String] {
        var values: [String] = []
        var current = ""
        var quote: Character?
        for character in text.dropFirst() {
            if let activeQuote = quote {
                current.append(character)
                if character == activeQuote { quote = nil }
            } else if character == "\"" || character == "'" {
                quote = character
                current.append(character)
            } else if character == "," || character == "]" {
                values.append(YAMLScalar.value(of: current))
                current = ""
                if character == "]" { break }
            } else {
                current.append(character)
            }
        }
        return values.filter { !$0.isEmpty }
    }
}
