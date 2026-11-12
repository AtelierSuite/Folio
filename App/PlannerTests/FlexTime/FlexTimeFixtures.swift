import Foundation
@testable import Planner

enum FlexTimeFixtures {
    /// Saturday 2026-10-31 (UTC).
    static let day = HolidayDay(year: 2026, month: 10, day: 31)

    static func time(_ hour: Int, _ minute: Int = 0, day: Int = 31) -> Date {
        Fixtures.calendar.date(
            from: DateComponents(year: 2026, month: 10, day: day, hour: hour, minute: minute)
        ) ?? .distantPast
    }

    static var morningEvents: [CalendarEvent] {
        [
            Fixtures.event(local: "breakfast", start: time(8)),
            Fixtures.event(local: "market", start: time(10)),
            Fixtures.event(local: "lunch", start: time(12, 30))
        ]
    }

    static func event(_ local: String, start: Date, calendarIdentifier: String) -> CalendarEvent {
        CalendarEvent(
            reference: Fixtures.reference(local: local),
            calendarIdentifier: calendarIdentifier,
            title: local,
            startDate: start,
            endDate: start.addingTimeInterval(3600)
        )
    }

    static func makeDefaults() -> UserDefaults {
        UserDefaults(suiteName: "FlexTimeTests.\(UUID().uuidString)") ?? .standard
    }

    static func night(endingAt end: Date, hours: Double = 8) -> SleepSession {
        SleepSession(segments: [
            SleepSegment(
                stage: .core,
                interval: DateInterval(start: end.addingTimeInterval(-hours * 3600), end: end),
                source: SleepFixtures.watch
            )
        ])
    }
}
