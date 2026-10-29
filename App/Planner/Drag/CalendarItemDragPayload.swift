import Foundation

/// What a month view chip carries when it's dragged: the entry and the day it was picked up
/// from, so a multi-day event moves by the number of days it was dragged.
public struct CalendarItemDragPayload: Sendable, Hashable {
    public static let prefix = "folio-calendar-item:"

    public let entryIdentifier: String
    public let sourceDay: Date

    public init(entryIdentifier: String, sourceDay: Date) {
        self.entryIdentifier = entryIdentifier
        self.sourceDay = sourceDay
    }

    public init?(_ string: String) {
        guard string.hasPrefix(Self.prefix) else { return nil }
        let body = string.dropFirst(Self.prefix.count)
        guard let separator = body.firstIndex(of: "|"),
              let interval = TimeInterval(body[body.startIndex..<separator]) else { return nil }
        let identifier = String(body[body.index(after: separator)...])
        guard !identifier.isEmpty else { return nil }
        self.init(entryIdentifier: identifier, sourceDay: Date(timeIntervalSinceReferenceDate: interval))
    }

    public var string: String {
        "\(Self.prefix)\(sourceDay.timeIntervalSinceReferenceDate)|\(entryIdentifier)"
    }
}
