import Foundation
import Testing
@testable import Planner

struct WidgetDayShiftTests {
    private func date(day: Int = 6, hour: Int) -> Date {
        Fixtures.date(2026, 11, day, hour: hour)
    }

    private var snapshot: WidgetSnapshot {
        WidgetSnapshot(
            events: [
                Fixtures.event(local: "standup", start: date(hour: 9)),
                Fixtures.event(local: "dentist", start: date(hour: 14)),
                Fixtures.event(local: "dinner", start: date(hour: 19)),
                Fixtures.event(local: "market", start: date(day: 7, hour: 10))
            ],
            alarmDates: [date(day: 7, hour: 7), date(day: 8, hour: 7)]
        )
    }

    @Test func phaseFollowsTheClock() {
        #expect(WidgetDayPhase(at: date(hour: 7), calendar: Fixtures.calendar) == .morning)
        #expect(WidgetDayPhase(at: date(hour: 11), calendar: Fixtures.calendar) == .daytime)
        #expect(WidgetDayPhase(at: date(hour: 18), calendar: Fixtures.calendar) == .evening)
    }

    @Test func morningLeadsWithTheFirstEvent() {
        let shift = snapshot.dayShift(at: date(hour: 7), calendar: Fixtures.calendar)
        #expect(shift.primaryEvent?.title == "standup")
        #expect(shift.remainingCount == 3)
        #expect(shift.alarmDate == nil)
    }

    @Test func daytimeLeadsWithWhatIsNext() {
        let shift = snapshot.dayShift(at: date(hour: 12), calendar: Fixtures.calendar)
        #expect(shift.primaryEvent?.title == "dentist")
        #expect(shift.laterEvents.map(\.title) == ["dinner"])
    }

    @Test func eveningLooksAtTomorrowAndItsAlarm() {
        let shift = snapshot.dayShift(at: date(hour: 21), calendar: Fixtures.calendar)
        #expect(shift.primaryEvent?.title == "market")
        #expect(shift.laterEvents.isEmpty)
        #expect(shift.alarmDate == date(day: 7, hour: 7))
    }

    @Test func boundariesCoverBothPhaseChanges() {
        let boundaries = WidgetDayPhase.boundaries(on: date(hour: 7), calendar: Fixtures.calendar)
        #expect(boundaries == [date(hour: 11), date(hour: 18)])
    }
}
