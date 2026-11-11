import Foundation
import Testing
@testable import Planner

struct FlexTimeScheduleTests {
    private typealias Fixture = FlexTimeFixtures
    private let schedule = FlexTimeSchedule(delays: [FlexTimeFixtures.day: 3 * 3600])

    @Test func timedEventsOnTheDayMoveLaterAndKeepTheirCalendarTimes() {
        let delayed = schedule.applying(to: Fixture.morningEvents, calendar: Fixtures.calendar)
        #expect(delayed.map(\.startDate) == [Fixture.time(11), Fixture.time(13), Fixture.time(15, 30)])
        #expect(delayed.map(\.endDate) == [Fixture.time(12), Fixture.time(14), Fixture.time(16, 30)])
        #expect(delayed.map(\.scheduledStartDate) == Fixture.morningEvents.map(\.startDate))
        #expect(delayed.map(\.reference) == Fixture.morningEvents.map(\.reference))
        #expect(delayed.map(\.withoutFlexTime) == Fixture.morningEvents)
    }

    @Test func otherDaysAndAllDayEventsStayPut() {
        let tomorrow = Fixtures.event(local: "brunch", start: Fixture.time(9, day: 30))
        let allDay = CalendarEvent(
            reference: Fixtures.reference(local: "festival"),
            calendarIdentifier: "calendar-1",
            title: "festival",
            startDate: Fixture.time(0),
            endDate: Fixture.time(0).addingTimeInterval(86400),
            isAllDay: true
        )
        #expect(schedule.applying(to: [tomorrow, allDay], calendar: Fixtures.calendar) == [tomorrow, allDay])
    }

    @Test func applyingTwiceDelaysOnlyOnce() {
        let once = schedule.applying(to: Fixture.morningEvents, calendar: Fixtures.calendar)
        #expect(schedule.applying(to: once, calendar: Fixtures.calendar) == once)
    }

    @Test func absoluteAlarmsMoveWithTheEvent() {
        let event = NotificationFixtures.event(
            "breakfast", start: Fixture.time(8), alarms: [.absolute(date: Fixture.time(7, 30)), .relative(offset: -600)]
        )
        let delayed = schedule.applying(to: [event], calendar: Fixtures.calendar)
        #expect(delayed.first?.alarms == [.absolute(date: Fixture.time(10, 30)), .relative(offset: -600)])
    }

    @Test func fetchReachesBackByTheLongestDelay() {
        let interval = DateInterval(start: Fixture.time(12), end: Fixture.time(18))
        let widened = DateInterval(start: Fixture.time(9), end: Fixture.time(18))
        #expect(schedule.fetchInterval(covering: interval) == widened)
        #expect(FlexTimeSchedule.none.fetchInterval(covering: interval) == interval)
    }

    @Test func droppedIntervalIsSavedAtItsCalendarTime() {
        let dropped = DateInterval(start: Fixture.time(14), duration: 3600)
        #expect(
            schedule.scheduledInterval(displayedAs: dropped, calendar: Fixtures.calendar)
                == DateInterval(start: Fixture.time(11), duration: 3600)
        )
        let nextDay = DateInterval(start: Fixture.time(14, day: 30), duration: 3600)
        #expect(schedule.scheduledInterval(displayedAs: nextDay, calendar: Fixtures.calendar) == nextDay)
    }

    @Test func dataSourceReturnsEventsDelayedIntoTheInterval() async {
        let source = FakeCalendarDataSource(events: Fixture.morningEvents)
        let afternoon = DateInterval(start: Fixture.time(15), end: Fixture.time(18))
        let events = await source.flexTimeEvents(in: afternoon, schedule: schedule, calendar: Fixtures.calendar)
        #expect(events.map(\.title) == ["lunch"])
        #expect(await source.flexTimeEvents(in: afternoon, schedule: .none, calendar: Fixtures.calendar).isEmpty)
    }
}
