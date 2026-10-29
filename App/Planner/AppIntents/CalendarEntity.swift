import AppIntents
import Foundation

public struct CalendarEntity: AppEntity, Identifiable, Sendable {
    public static let typeDisplayRepresentation = TypeDisplayRepresentation(
        name: LocalizedStringResource("CalendarEntity.TypeName", table: "Intents", bundle: #bundle)
    )
    public static let defaultQuery = CalendarEntityQuery()

    public let id: String
    public let title: String
    public let sourceTitle: String

    public init(id: String, title: String, sourceTitle: String) {
        self.id = id
        self.title = title
        self.sourceTitle = sourceTitle
    }

    public init(_ calendar: PlannerCalendar) {
        self.init(id: calendar.id, title: calendar.title, sourceTitle: calendar.sourceTitle)
    }

    public var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)", subtitle: "\(sourceTitle)")
    }
}

public struct CalendarEntityQuery: EntityQuery {
    public init() {}

    public func entities(for identifiers: [CalendarEntity.ID]) async throws -> [CalendarEntity] {
        PlannerCalendarLookup.calendars(of: .event, withIdentifiers: identifiers).map(CalendarEntity.init)
    }

    public func suggestedEntities() async throws -> [CalendarEntity] {
        PlannerCalendarLookup.calendars(of: .event).map(CalendarEntity.init)
    }
}
