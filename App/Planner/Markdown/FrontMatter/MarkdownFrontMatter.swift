import Foundation

public struct MarkdownFrontMatter: Sendable, Equatable {
    struct Entry: Sendable, Equatable {
        var key: String?
        var lines: [String]
    }

    var entries: [Entry]
    var closingDelimiter: String

    public init() {
        entries = []
        closingDelimiter = MarkdownNoteFile.openingDelimiter
    }

    init(lines: [String], closingDelimiter: String) {
        var entries: [Entry] = []
        for line in lines {
            if let key = Self.key(startingLine: line) {
                entries.append(Entry(key: key, lines: [line]))
            } else if entries.isEmpty {
                entries.append(Entry(key: nil, lines: [line]))
            } else {
                entries[entries.count - 1].lines.append(line)
            }
        }
        self.entries = entries
        self.closingDelimiter = closingDelimiter
    }

    public var isEmpty: Bool {
        entries.isEmpty
    }

    public var keys: [String] {
        entries.compactMap(\.key)
    }

    var lines: [String] {
        entries.flatMap(\.lines)
    }

    public func rawValue(forKey key: String) -> String? {
        guard let entry = entries.first(where: { $0.key == key }), let firstLine = entry.lines.first,
              let colon = firstLine.firstIndex(of: ":") else { return nil }
        let inlineValue = firstLine[firstLine.index(after: colon)...].trimmingCharacters(in: .whitespaces)
        return ([inlineValue] + entry.lines.dropFirst()).joined(separator: "\n")
    }

    public func value(forKey key: String) -> String? {
        guard let entry = entries.first(where: { $0.key == key }), let firstLine = entry.lines.first,
              let colon = firstLine.firstIndex(of: ":") else { return nil }
        let scalar = YAMLScalar.value(of: String(firstLine[firstLine.index(after: colon)...]))
        return scalar.isEmpty ? nil : scalar
    }

    public mutating func setValue(_ value: String?, forKey key: String) {
        guard let value, !value.isEmpty else {
            removeValue(forKey: key)
            return
        }
        setLines(["\(key): \(YAMLScalar.formatted(value))"], forKey: key)
    }

    public mutating func removeValue(forKey key: String) {
        entries.removeAll { $0.key == key }
    }

    mutating func setLines(_ lines: [String], forKey key: String) {
        if let index = entries.firstIndex(where: { $0.key == key }) {
            entries[index].lines = lines
        } else {
            entries.append(Entry(key: key, lines: lines))
        }
    }

    private static func key(startingLine line: String) -> String? {
        guard let first = line.first, !first.isWhitespace, first != "#", first != "-",
              let colon = line.firstIndex(of: ":") else { return nil }
        let afterColon = line.index(after: colon)
        guard afterColon == line.endIndex || line[afterColon].isWhitespace else { return nil }
        let key = YAMLScalar.value(of: String(line[..<colon]))
        return key.isEmpty ? nil : key
    }
}
