import Foundation

/// The parts of a linked note a widget shows. The note itself lives where the extension can't reach it.
public struct EventNoteDigest: Sendable, Hashable, Codable {
    public struct ChecklistItem: Sendable, Hashable, Codable, Identifiable {
        public let text: String
        public let isDone: Bool

        public init(text: String, isDone: Bool) {
            self.text = text
            self.isDone = isDone
        }

        public var id: String { text }
    }

    public static let lookAheadDays = 7
    public static let summaryLength = 160
    public static let checklistLimit = 6

    public let notePath: String
    public let title: String
    public let summary: String
    public let checklist: [ChecklistItem]

    public init(notePath: String, title: String, summary: String, checklist: [ChecklistItem]) {
        self.notePath = notePath
        self.title = title
        self.summary = summary
        self.checklist = checklist
    }

    public init(notePath: String, title: String, text: String) {
        let lines = text.split(whereSeparator: \.isNewline).map { $0.trimmingCharacters(in: .whitespaces) }
        let checklist = lines.compactMap(Self.checklistItem).prefix(Self.checklistLimit)
        let summary = lines.first(where: Self.isProse).map { MarkdownDocument(parsing: $0).plainText } ?? ""
        self.init(
            notePath: notePath,
            title: title,
            summary: String(summary.prefix(Self.summaryLength)),
            checklist: Array(checklist)
        )
    }

    public var noteURL: URL? {
        NoteDeepLink.url(forRelativePath: notePath)
    }

    public var openItems: [ChecklistItem] {
        checklist.filter { !$0.isDone }
    }

    private static func isProse(_ line: String) -> Bool {
        !line.isEmpty && !line.hasPrefix("#") && checklistItem(line) == nil
    }

    private static func checklistItem(_ line: String) -> ChecklistItem? {
        guard let match = line.wholeMatch(of: /[-*+] \[([ xX])\] (.+)/) else { return nil }
        let text = MarkdownDocument(parsing: String(match.output.2)).plainText
        return ChecklistItem(text: text, isDone: match.output.1 != " ")
    }
}
