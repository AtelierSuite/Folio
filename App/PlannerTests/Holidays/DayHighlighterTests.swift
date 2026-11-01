import Foundation
import Testing
@testable import Planner

struct DayHighlighterTests {
    static var tokyo: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo") ?? .gmt
        return calendar
    }

    static func date(_ year: Int, _ month: Int, _ day: Int, in calendar: Calendar = tokyo) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day)) ?? .distantPast
    }

    static let laborThanksgiving = Holiday(day: HolidayDay(year: 2026, month: 11, day: 23), name: "勤労感謝の日")

    @Test func highlightsWeekendWeekdays() {
        let highlighter = DayHighlighter(weekendWeekdays: [1, 7])
        #expect(highlighter.isHighlighted(Self.date(2026, 11, 1), calendar: Self.tokyo))
        #expect(!highlighter.isHighlighted(Self.date(2026, 11, 2), calendar: Self.tokyo))
    }

    @Test func highlightsHolidaysByName() {
        let highlighter = DayHighlighter(holidays: [Self.laborThanksgiving])
        #expect(highlighter.holidayName(on: Self.date(2026, 11, 23), calendar: Self.tokyo) == "勤労感謝の日")
        #expect(highlighter.isHighlighted(Self.date(2026, 11, 23), calendar: Self.tokyo))
        #expect(!highlighter.isHighlighted(Self.date(2026, 11, 24), calendar: Self.tokyo))
    }

    @Test func matchesHolidaysUnderNonGregorianCalendars() {
        var japanese = Calendar(identifier: .japanese)
        japanese.timeZone = Self.tokyo.timeZone
        let highlighter = DayHighlighter(holidays: [Self.laborThanksgiving])
        #expect(highlighter.holidayName(on: Self.date(2026, 11, 23), calendar: japanese) == "勤労感謝の日")
    }

    @Test func joinsHolidaysSharingADay() {
        let day = HolidayDay(year: 2026, month: 5, day: 5)
        let highlighter = DayHighlighter(holidays: [Holiday(day: day, name: "A"), Holiday(day: day, name: "B")])
        #expect(highlighter.holidayNames[day] == "A, B")
    }

    @Test func unsupportedOrMissingRegionsResolveToNil() {
        #expect(DayHighlightSettings.resolvedRegionCode(stored: "", locale: Locale(identifier: "ja_JP")) == "JP")
        #expect(DayHighlightSettings.resolvedRegionCode(stored: "US", locale: Locale(identifier: "ja_JP")) == "US")
        #expect(DayHighlightSettings.resolvedRegionCode(stored: "", locale: Locale(identifier: "zh_TW")) == nil)
    }
}
