import Foundation
import Testing
@testable import Planner

struct BirthdayOrderTests {
    typealias Support = TimelineTestSupport

    @Test func birthdaysTakeTheTopAllDayLane() {
        let engine = Support.engine(startingOn: Support.date(2026, 10, 26), count: 7)
        var birthday = Support.entry(
            "birthday", from: Support.date(2026, 10, 28), to: Support.date(2026, 10, 29), isAllDay: true
        )
        birthday.isBirthday = true
        let layout = engine.layout([
            Support.entry("trip", from: Support.date(2026, 10, 26), to: Support.date(2026, 10, 30), isAllDay: true),
            Support.entry("holiday", from: Support.date(2026, 10, 28), to: Support.date(2026, 10, 29), isAllDay: true),
            birthday
        ])
        let lanes = Dictionary(uniqueKeysWithValues: layout.allDayPlacements.map { ($0.entry.id, $0.lane) })
        #expect(lanes["birthday"] == 0)
        #expect(lanes["trip"] == 1)
        #expect(lanes["holiday"] == 2)
    }

    @Test func birthdaysComeFirstInLists() {
        let day = Fixtures.date(2026, 10, 31)
        let events = [
            NotificationFixtures.event("holiday", start: day, hours: 24, isAllDay: true),
            NotificationFixtures.event("birthday", start: day, hours: 24, isAllDay: true, isBirthday: true),
            NotificationFixtures.event("meeting", start: day.addingTimeInterval(9 * 3600))
        ]
        #expect(events.birthdaysFirst.map(\.title) == ["birthday", "holiday", "meeting"])
    }
}
