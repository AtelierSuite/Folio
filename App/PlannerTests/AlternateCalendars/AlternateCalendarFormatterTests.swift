import Foundation
import Testing
@testable import Planner

struct AlternateCalendarFormatterTests {
    private let utc = TimeZone(identifier: "UTC") ?? .gmt
    private let english = Locale(identifier: "en_US")

    private func formatter(
        _ alternateCalendar: AlternateCalendar,
        locale: Locale? = nil
    ) -> AlternateCalendarFormatter {
        AlternateCalendarFormatter(alternateCalendar: alternateCalendar, timeZone: utc, locale: locale ?? english)
    }

    private func firstDayOfMonth(containing date: Date, in formatter: AlternateCalendarFormatter) -> Date {
        formatter.calendar.dateInterval(of: .month, for: date)?.start ?? date
    }

    @Test func calendarsSharingGregorianDaysHaveNoDayLabel() {
        #expect(formatter(.japanese).dayLabel(for: Fixtures.date(2026, 10, 31)) == nil)
        #expect(formatter(.buddhist).dayLabel(for: Fixtures.date(2026, 10, 31)) == nil)
    }

    @Test func showsTheDayOfTheAlternateMonth() {
        #expect(formatter(.hebrew).dayLabel(for: Fixtures.date(2026, 10, 31)) == "20")
    }

    @Test func showsTheMonthNameOnItsFirstDay() {
        let hebrew = formatter(.hebrew)
        let firstDay = firstDayOfMonth(containing: Fixtures.date(2026, 10, 31), in: hebrew)
        #expect(hebrew.dayLabel(for: firstDay) == "Heshvan")
    }

    @Test func chineseMonthsAreNumericOutsideEastAsianLanguages() {
        let chinese = formatter(.chinese)
        let firstDay = firstDayOfMonth(containing: Fixtures.date(2026, 10, 31), in: chinese)
        #expect(chinese.dayLabel(for: firstDay) == "9/1")
    }

    @Test func chineseDaysUseChineseNumeralsInChinese() {
        let chinese = formatter(.chinese, locale: Locale(identifier: "zh_Hans_CN"))
        #expect(chinese.dayLabel(for: Fixtures.date(2026, 10, 31)) == "廿二")
    }

    @Test func monthTitleSpansEveryAlternateMonthInTheInterval() {
        let interval = DateInterval(start: Fixtures.date(2026, 10, 1), end: Fixtures.date(2026, 11, 1))
        let title = formatter(.hebrew).monthTitle(for: interval)
        #expect(title.contains("Tishri"))
        #expect(title.contains("Heshvan"))
        #expect(title.contains("5787"))
    }

    @Test func japaneseMonthTitleShowsTheEra() {
        let interval = DateInterval(start: Fixtures.date(2026, 10, 1), end: Fixtures.date(2026, 11, 1))
        let title = formatter(.japanese, locale: Locale(identifier: "ja_JP")).monthTitle(for: interval)
        #expect(title == "令和8年10月")
    }

    @Test func everyCalendarHasALocalizedName() {
        for alternateCalendar in AlternateCalendar.allCases {
            #expect(alternateCalendar.displayName(in: english) != alternateCalendar.rawValue)
        }
    }
}
