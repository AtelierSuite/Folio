import Foundation

/// The travel time each upcoming leave alert was planned with, reused after a relaunch when directions are down.
public struct LeaveTravelTimeCache: @unchecked Sendable {
    public static let storageKey = "LeaveAlerts.TravelTimes"

    struct Entry: Codable, Equatable {
        let destination: PlannerCoordinate
        let transport: TravelTransport
        let travelTime: TimeInterval
        let eventStart: Date
    }

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = AppGroup.userDefaults) {
        self.defaults = defaults
    }

    var entries: [String: Entry] {
        get {
            guard let data = defaults.data(forKey: Self.storageKey) else { return [:] }
            return (try? JSONDecoder().decode([String: Entry].self, from: data)) ?? [:]
        }
        nonmutating set {
            defaults.set(try? JSONEncoder().encode(newValue), forKey: Self.storageKey)
        }
    }

    func travelTime(
        for event: CalendarEvent, to destination: PlannerCoordinate, by transport: TravelTransport
    ) -> TimeInterval? {
        guard let entry = entries[event.id], entry.destination == destination, entry.transport == transport else {
            return nil
        }
        return entry.travelTime
    }

    func record(_ alerts: [LeaveAlert], now: Date) {
        var updated = entries.filter { $0.value.eventStart > now }
        for alert in alerts {
            updated[alert.event.id] = Entry(
                destination: alert.destination,
                transport: alert.transport,
                travelTime: alert.travelTime,
                eventStart: alert.event.startDate
            )
        }
        entries = updated
    }
}
