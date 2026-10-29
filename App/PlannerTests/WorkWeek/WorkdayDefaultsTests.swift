import Foundation
import Testing
@testable import Planner

struct WorkdayDefaultsTests {
    static func calendar(_ localeIdentifier: String) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: localeIdentifier)
        calendar.timeZone = TimelineTestSupport.newYork
        return calendar
    }

    @Test(arguments: ["en_US", "en_GB", "fr_FR", "de_DE", "ja_JP", "zh_CN", "ko_KR", "vi_VN"])
    func saturdaySundayWeekendGivesMondayToFriday(localeIdentifier: String) {
        #expect(Self.calendar(localeIdentifier).localeWorkdays == [2, 3, 4, 5, 6])
    }

    @Test(arguments: ["ar_SA", "he_IL", "ar_EG", "ar_KW"])
    func fridaySaturdayWeekendGivesSundayToThursday(localeIdentifier: String) {
        #expect(Self.calendar(localeIdentifier).localeWorkdays == [1, 2, 3, 4, 5])
    }

    @Test func sundayOnlyWeekendGivesMondayToSaturday() {
        #expect(Self.calendar("en_IN").localeWorkdays == [2, 3, 4, 5, 6, 7])
    }

    @Test func orderedWeekdaysStartOnTheFirstWeekday() {
        var calendar = Self.calendar("en_US")
        #expect(calendar.orderedWeekdays == [1, 2, 3, 4, 5, 6, 7])
        calendar.firstWeekday = 2
        #expect(calendar.orderedWeekdays == [2, 3, 4, 5, 6, 7, 1])
        calendar.firstWeekday = 7
        #expect(calendar.orderedWeekdays == [7, 1, 2, 3, 4, 5, 6])
    }
}
