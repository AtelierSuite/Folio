import Foundation
import Testing
@testable import Planner

struct FixedCalendarsTests {
    @Test func keepsOneCalendarPerTimeZone() throws {
        let tokyo = try #require(TimeZone(identifier: "Asia/Tokyo"))
        let losAngeles = try #require(TimeZone(identifier: "America/Los_Angeles"))
        let instant = Date(timeIntervalSince1970: 1_798_750_800)
        #expect(HolidayDay(date: instant, timeZone: tokyo) == HolidayDay(year: 2027, month: 1, day: 1))
        #expect(HolidayDay(date: instant, timeZone: losAngeles) == HolidayDay(year: 2026, month: 12, day: 31))
        #expect(FixedCalendars.gregorian(in: tokyo).timeZone == tokyo)
        #expect(FixedCalendars.iso8601(in: tokyo).identifier == .iso8601)
    }
}
