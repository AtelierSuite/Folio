import AppIntents
import Foundation

public struct EventEntityQuery: EntityStringQuery {
    public init() {}

    public func entities(for identifiers: [EventEntity.ID]) async throws -> [EventEntity] {
        await EventLookup().events(withIdentifiers: identifiers).map(EventEntity.init)
    }

    public func entities(matching string: String) async throws -> [EventEntity] {
        await EventLookup().events(matching: string).map(EventEntity.init)
    }

    public func suggestedEntities() async throws -> [EventEntity] {
        await EventLookup().upcomingEvents().map(EventEntity.init)
    }
}
