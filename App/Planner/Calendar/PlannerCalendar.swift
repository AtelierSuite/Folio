import Foundation

public struct PlannerCalendar: Identifiable, Sendable, Hashable {
    public let id: String
    public let title: String
    public let kind: CalendarItemKind
    public let color: PlannerColor
    public let sourceIdentifier: String
    public let sourceTitle: String
    public let sourceType: CalendarSourceType
    public let isReadOnly: Bool

    public init(
        id: String,
        title: String,
        kind: CalendarItemKind,
        color: PlannerColor,
        sourceIdentifier: String,
        sourceTitle: String,
        sourceType: CalendarSourceType,
        isReadOnly: Bool
    ) {
        self.id = id
        self.title = title
        self.kind = kind
        self.color = color
        self.sourceIdentifier = sourceIdentifier
        self.sourceTitle = sourceTitle
        self.sourceType = sourceType
        self.isReadOnly = isReadOnly
    }
}
