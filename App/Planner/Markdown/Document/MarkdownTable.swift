import Foundation

public struct MarkdownTable: Sendable, Equatable {
    public typealias Row = [[MarkdownInline]]

    public let columnAlignments: [MarkdownTableAlignment]
    public let header: Row
    public let rows: [Row]

    public init(columnAlignments: [MarkdownTableAlignment], header: Row, rows: [Row]) {
        self.columnAlignments = columnAlignments
        self.header = header
        self.rows = rows
    }

    public var columnCount: Int {
        max(columnAlignments.count, header.count, rows.map(\.count).max() ?? 0)
    }
}

public enum MarkdownTableAlignment: Sendable, Equatable {
    case leading
    case center
    case trailing
}
