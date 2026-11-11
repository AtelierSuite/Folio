import Foundation
import Testing
@testable import Planner

struct FlexTimeStorageTests {
    private typealias Fixture = FlexTimeFixtures

    @Test func weekendsAndPublicHolidaysAreOnByDefault() {
        let storage = FlexTimeStorage(defaults: Fixture.makeDefaults())
        #expect(storage.enabledDayKinds == [.weekend, .publicHoliday])
        storage.setEnabled(true, on: .weekday)
        storage.setEnabled(false, on: .weekend)
        #expect(storage.enabledDayKinds == [.weekday, .publicHoliday])
    }

    @Test func delayLastsForItsDayOnly() {
        let storage = FlexTimeStorage(defaults: Fixture.makeDefaults())
        storage.setDelay(3600, on: HolidayDay(year: 2026, month: 10, day: 30))
        storage.setDelay(7200, on: Fixture.day)
        #expect(storage.schedule() == FlexTimeSchedule(delays: [Fixture.day: 7200]))
        storage.setDelay(0, on: Fixture.day)
        #expect(storage.schedule().isEmpty)
    }

    @Test func firstOpenOfTheDayIsKept() {
        let storage = FlexTimeStorage(defaults: Fixture.makeDefaults())
        storage.recordOpen(at: Fixture.time(10, 30), on: Fixture.day)
        storage.recordOpen(at: Fixture.time(12), on: Fixture.day)
        #expect(storage.firstOpen(on: Fixture.day) == Fixture.time(10, 30))
        #expect(storage.firstOpen(on: HolidayDay(year: 2026, month: 11, day: 1)) == nil)
    }
}
