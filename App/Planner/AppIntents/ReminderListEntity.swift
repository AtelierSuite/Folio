import AppIntents
import Foundation

public struct ReminderListEntity: AppEntity, Identifiable, Sendable {
    public static let typeDisplayRepresentation = TypeDisplayRepresentation(
        name: LocalizedStringResource("ReminderListEntity.TypeName", table: "Intents", bundle: #bundle)
    )
    public static let defaultQuery = ReminderListEntityQuery()

    public let id: String
    public let title: String
    public let sourceTitle: String

    public init(id: String, title: String, sourceTitle: String) {
        self.id = id
        self.title = title
        self.sourceTitle = sourceTitle
    }

    public init(_ list: PlannerCalendar) {
        self.init(id: list.id, title: list.title, sourceTitle: list.sourceTitle)
    }

    public var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)", subtitle: "\(sourceTitle)")
    }
}

public struct ReminderListEntityQuery: EntityQuery {
    public init() {}

    public func entities(for identifiers: [ReminderListEntity.ID]) async throws -> [ReminderListEntity] {
        PlannerCalendarLookup.calendars(of: .reminder, withIdentifiers: identifiers).map(ReminderListEntity.init)
    }

    public func suggestedEntities() async throws -> [ReminderListEntity] {
        PlannerCalendarLookup.calendars(of: .reminder).map(ReminderListEntity.init)
    }
}
