import Foundation
@testable import Planner

extension Fixtures {
    /// `Fixtures.event` shares one title and start in every reference, which matches any other.
    static func countdownEvent(local: String, start: Date, hours: Double = 1) -> CalendarEvent {
        CalendarEvent(
            reference: reference(external: "external-\(local)", local: local, title: local, start: start),
            calendarIdentifier: "calendar-1",
            title: local,
            startDate: start,
            endDate: start.addingTimeInterval(hours * 3600)
        )
    }
}
