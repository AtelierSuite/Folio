import Foundation
import Testing
@testable import Planner

struct CalendarAlarmTests {
    private let start = Fixtures.date(2026, 10, 29, hour: 9)

    @Test func relativeAlarmFiresRelativeToTheAnchor() {
        #expect(CalendarAlarm.relative(offset: -600).fireDate(relativeTo: start) == start.addingTimeInterval(-600))
        #expect(CalendarAlarm.relative(offset: 0).fireDate(relativeTo: start) == start)
    }

    @Test func relativeAlarmWithoutAnchorHasNoFireDate() {
        #expect(CalendarAlarm.relative(offset: -600).fireDate(relativeTo: nil) == nil)
    }

    @Test func absoluteAlarmIgnoresTheAnchor() {
        let date = Fixtures.date(2026, 11, 1, hour: 8)
        #expect(CalendarAlarm.absolute(date: date).fireDate(relativeTo: start) == date)
        #expect(CalendarAlarm.absolute(date: date).fireDate(relativeTo: nil) == date)
    }

    @Test func reminderAlarmsMapToCalendarAlarms() {
        let date = Fixtures.date(2026, 11, 1, hour: 8)
        #expect(CalendarAlarm(ReminderAlarm.relative(-300)) == .relative(offset: -300))
        #expect(CalendarAlarm(ReminderAlarm.absolute(date)) == .absolute(date: date))
    }

    @Test func snapshotsDefaultToNoAlarms() {
        #expect(Fixtures.event(local: "standup", start: start).alarms.isEmpty)
        #expect(Fixtures.reminder(local: "call", due: start).alarms.isEmpty)
    }
}
