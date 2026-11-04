import Foundation
import Testing
@testable import Planner

struct HourlyScheduleTests {
    private let now = Fixtures.date(2026, 10, 29, hour: 10).addingTimeInterval(30 * 60)

    private func schedule(_ events: [CalendarEvent], laneLimit: Int = 4) -> HourlySchedule {
        HourlySchedule(events: events, at: now, calendar: Fixtures.calendar, laneLimit: laneLimit)
    }

    private func allDayEvent(_ title: String) -> CalendarEvent {
        CalendarEvent(
            reference: Fixtures.reference(local: title),
            calendarIdentifier: "calendar-1",
            title: title,
            startDate: Fixtures.date(2026, 10, 29),
            endDate: Fixtures.date(2026, 10, 30),
            isAllDay: true
        )
    }

    @Test func windowStartsAtTheCurrentHour() {
        let schedule = schedule([])
        #expect(schedule.hours.count == 6)
        #expect(schedule.hours.first == Fixtures.date(2026, 10, 29, hour: 10))
        #expect(schedule.hours.last == Fixtures.date(2026, 10, 29, hour: 15))
        #expect(schedule.nowFraction == 0.5 / 6)
    }

    @Test func positionsEventsAsFractionsOfTheWindow() throws {
        let event = Fixtures.event(local: "lunch", start: Fixtures.date(2026, 10, 29, hour: 13), hours: 1.5)
        let strip = try #require(schedule([event]).strips.first)
        #expect(strip.startFraction == 0.5)
        #expect(strip.endFraction == 4.5 / 6)
    }

    @Test func clipsEventsToTheWindowAndSkipsOthers() throws {
        let events = [
            Fixtures.event(local: "breakfast", start: Fixtures.date(2026, 10, 29, hour: 7)),
            Fixtures.event(local: "standup", start: Fixtures.date(2026, 10, 29, hour: 9), hours: 2),
            Fixtures.event(local: "offsite", start: Fixtures.date(2026, 10, 29, hour: 15), hours: 5),
            Fixtures.event(local: "dinner", start: Fixtures.date(2026, 10, 29, hour: 19))
        ]
        let strips = schedule(events).strips
        #expect(strips.map(\.event.title) == ["standup", "offsite"])
        #expect(strips.first?.startFraction == 0)
        #expect(strips.last?.endFraction == 1)
    }

    @Test func overlappingEventsTakeSeparateLanesAndLaterOnesReuseThem() {
        let events = [
            Fixtures.event(local: "first", start: Fixtures.date(2026, 10, 29, hour: 11)),
            Fixtures.event(local: "overlap", start: Fixtures.date(2026, 10, 29, hour: 11), hours: 2),
            Fixtures.event(local: "after", start: Fixtures.date(2026, 10, 29, hour: 12))
        ]
        #expect(schedule(events).strips.map(\.lane) == [0, 1, 0])
    }

    @Test func countsEventsThatDoNotFitInTheLanes() {
        let events = (0..<3).map {
            Fixtures.event(local: "event-\($0)", start: Fixtures.date(2026, 10, 29, hour: 11))
        }
        let schedule = schedule(events, laneLimit: 2)
        #expect(schedule.strips.count == 2)
        #expect(schedule.hiddenCount == 1)
    }

    @Test func allDayEventsShareOneFullWidthLane() throws {
        let timed = Fixtures.event(local: "standup", start: Fixtures.date(2026, 10, 29, hour: 11))
        let schedule = schedule([allDayEvent("holiday"), allDayEvent("birthday"), timed])
        let allDay = try #require(schedule.strips.first)
        #expect(allDay.event.title == "holiday")
        #expect(allDay.lane == 0)
        #expect(allDay.startFraction == 0)
        #expect(allDay.endFraction == 1)
        #expect(schedule.strips.last?.lane == 1)
        #expect(schedule.hiddenCount == 1)
    }

    @Test func zeroLengthEventsStayVisible() throws {
        let event = Fixtures.event(local: "ping", start: Fixtures.date(2026, 10, 29, hour: 12), hours: 0)
        let strip = try #require(schedule([event]).strips.first)
        #expect(strip.endFraction > strip.startFraction)
    }
}
