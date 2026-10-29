import AppIntents
import Foundation

public struct ReminderEntityQuery: EntityStringQuery {
    public init() {}

    public func entities(for identifiers: [ReminderEntity.ID]) async throws -> [ReminderEntity] {
        await ReminderLookup().reminders(withIdentifiers: identifiers).map(ReminderEntity.init)
    }

    public func entities(matching string: String) async throws -> [ReminderEntity] {
        await ReminderLookup().reminders(matching: string).map(ReminderEntity.init)
    }

    public func suggestedEntities() async throws -> [ReminderEntity] {
        await ReminderLookup().suggestedReminders().map(ReminderEntity.init)
    }
}
