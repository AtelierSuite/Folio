import Foundation
import Testing
@testable import Planner

enum IntentTestSupport {
    static let now = Fixtures.date(2026, 10, 29, hour: 10)

    static func visibilityStorage(hiding hidden: Set<String> = []) throws -> CalendarVisibilityStorage {
        let defaults = try #require(UserDefaults(suiteName: "IntentTests.\(UUID().uuidString)"))
        let storage = CalendarVisibilityStorage(defaults: defaults)
        storage.hiddenCalendarIdentifiers = hidden
        return storage
    }

    static func event(
        _ title: String,
        start: Date,
        hours: Double = 1,
        calendarIdentifier: String = "work",
        location: String? = nil,
        notes: String? = nil,
        occurrence: Date? = nil
    ) -> CalendarEvent {
        CalendarEvent(
            reference: CalendarItemReference(
                externalIdentifier: "external-\(title)",
                localIdentifier: "local-\(title)",
                calendarIdentifier: calendarIdentifier,
                occurrenceDate: occurrence,
                title: title,
                startDate: start
            ),
            calendarIdentifier: calendarIdentifier,
            title: title,
            location: location,
            notes: notes,
            startDate: start,
            endDate: start.addingTimeInterval(hours * 3600),
            isRecurring: occurrence != nil
        )
    }
}
