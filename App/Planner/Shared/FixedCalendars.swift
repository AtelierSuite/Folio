import Foundation
import Synchronization

nonisolated enum FixedCalendars {
    private struct Key: Hashable {
        let identifier: Calendar.Identifier
        let timeZone: TimeZone
    }

    private static let cache = Mutex<[Key: Calendar]>([:])

    static func gregorian(in timeZone: TimeZone) -> Calendar {
        calendar(.gregorian, in: timeZone)
    }

    static func iso8601(in timeZone: TimeZone) -> Calendar {
        calendar(.iso8601, in: timeZone)
    }

    private static func calendar(_ identifier: Calendar.Identifier, in timeZone: TimeZone) -> Calendar {
        let key = Key(identifier: identifier, timeZone: timeZone)
        return cache.withLock { calendars in
            if let cached = calendars[key] {
                return cached
            }
            var calendar = Calendar(identifier: identifier)
            calendar.timeZone = timeZone
            calendars[key] = calendar
            return calendar
        }
    }
}
