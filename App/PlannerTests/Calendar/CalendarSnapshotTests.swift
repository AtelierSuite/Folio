import CoreGraphics
import Foundation
import Testing
@testable import Planner

struct CalendarSnapshotTests {
    private let day = DateInterval(start: Fixtures.date(2026, 10, 29), end: Fixtures.date(2026, 10, 30))

    @Test func eventOverlapsDayItSpans() {
        let overnight = Fixtures.event(local: "overnight", start: Fixtures.date(2026, 10, 28, hour: 22), hours: 4)
        #expect(overnight.overlaps(day))
    }

    @Test func eventEndingAtDayStartDoesNotOverlap() {
        let previous = Fixtures.event(local: "previous", start: Fixtures.date(2026, 10, 28, hour: 23))
        #expect(!previous.overlaps(day))
    }

    @Test func zeroLengthEventOverlapsWhenInside() {
        let marker = Fixtures.event(local: "marker", start: Fixtures.date(2026, 10, 29), hours: 0)
        #expect(marker.overlaps(day))
    }

    @Test func reminderIsDueOnlyInsideInterval() {
        #expect(Fixtures.reminder(local: "due", due: Fixtures.date(2026, 10, 29, hour: 12)).isDue(in: day))
        #expect(!Fixtures.reminder(local: "later", due: Fixtures.date(2026, 10, 30)).isDue(in: day))
        #expect(!Fixtures.reminder(local: "undated", due: nil).isDue(in: day))
    }

    @Test func colorConvertsFromCGColor() {
        let color = PlannerColor(CGColor(srgbRed: 1, green: 0.5, blue: 0, alpha: 1))
        #expect(abs(color.red - 1) < 0.01)
        #expect(abs(color.green - 0.5) < 0.01)
        #expect(abs(color.blue) < 0.01)
        #expect(PlannerColor(nil) == .gray)
    }
}
