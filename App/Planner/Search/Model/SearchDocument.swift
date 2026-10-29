import Foundation

public struct SearchDocument: Identifiable, Sendable, Hashable {
    public let id: String
    public let kind: SearchItemKind
    public let title: String
    public let detail: String?
    public let body: String
    public let date: Date?
    public let endDate: Date?
    public let isAllDay: Bool
    public let isCompleted: Bool
    public let containerIdentifier: String?
    public let color: PlannerColor?
    public let hasMeetingLink: Bool
    public let destination: AppDestination

    public init(
        id: String,
        kind: SearchItemKind,
        title: String,
        detail: String? = nil,
        body: String = "",
        date: Date? = nil,
        endDate: Date? = nil,
        isAllDay: Bool = false,
        isCompleted: Bool = false,
        containerIdentifier: String? = nil,
        color: PlannerColor? = nil,
        hasMeetingLink: Bool = false,
        destination: AppDestination
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.detail = detail
        self.body = body
        self.date = date
        self.endDate = endDate
        self.isAllDay = isAllDay
        self.isCompleted = isCompleted
        self.containerIdentifier = containerIdentifier
        self.color = color
        self.hasMeetingLink = hasMeetingLink
        self.destination = destination
    }

    var searchableText: String {
        [title, detail ?? "", body].joined(separator: "\n")
    }

    func isDated(in interval: DateInterval) -> Bool {
        guard let date else { return false }
        guard let endDate, endDate > date else {
            return interval.start <= date && date < interval.end
        }
        return date < interval.end && endDate > interval.start
    }
}
