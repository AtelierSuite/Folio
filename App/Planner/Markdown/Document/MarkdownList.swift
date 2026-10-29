import Foundation

public struct MarkdownList: Sendable, Equatable {
    public let isOrdered: Bool
    public let startIndex: Int
    public let items: [MarkdownListItem]

    public init(isOrdered: Bool, startIndex: Int, items: [MarkdownListItem]) {
        self.isOrdered = isOrdered
        self.startIndex = startIndex
        self.items = items
    }
}

public struct MarkdownListItem: Sendable, Equatable {
    public let checkbox: MarkdownCheckbox?
    public let blocks: [MarkdownBlock]
    public let sourceLine: Int

    public init(checkbox: MarkdownCheckbox?, blocks: [MarkdownBlock], sourceLine: Int) {
        self.checkbox = checkbox
        self.blocks = blocks
        self.sourceLine = sourceLine
    }
}

public enum MarkdownCheckbox: Sendable, Equatable {
    case checked
    case unchecked
}
