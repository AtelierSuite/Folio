import Foundation
import Testing
@testable import Planner

struct HolidayParserTests {
    @Test func cabinetOfficeCSVIsDecodedFromShiftJIS() throws {
        let csv = "国民の祝日・休日月日,国民の祝日・休日名称\r\n2026/1/1,元日\r\n2026/11/23,勤労感謝の日\r\n"
        let data = try #require(csv.data(using: .shiftJIS))
        let holidays = try HolidaySource.cabinetOfficeJapan.holidays(from: data)
        #expect(holidays == [
            Holiday(day: HolidayDay(year: 2026, month: 1, day: 1), name: "元日"),
            Holiday(day: HolidayDay(year: 2026, month: 11, day: 23), name: "勤労感謝の日")
        ])
    }

    @Test func govUKUsesEnglandAndWales() throws {
        let json = """
        {"england-and-wales":{"events":[{"title":"Boxing Day","date":"2026-12-28","notes":"Substitute day"}]},
         "scotland":{"events":[{"title":"St Andrew’s Day","date":"2026-11-30","notes":""}]}}
        """
        let holidays = try HolidaySource.govUK.holidays(from: Data(json.utf8))
        #expect(holidays == [Holiday(day: HolidayDay(year: 2026, month: 12, day: 28), name: "Boxing Day")])
    }

    @Test func nagerDateKeepsNationwidePublicHolidaysOnly() throws {
        let json = """
        [{"date":"2026-01-01","localName":"New Year's Day","global":true,"types":["Public","Bank"]},
         {"date":"2026-02-12","localName":"Lincoln's Birthday","global":false,"types":["Observance"]},
         {"date":"2026-04-03","localName":"Good Friday","global":false,"types":["Public"]},
         {"date":"2026-02-14","localName":"Valentine's Day","global":true,"types":["Observance"]}]
        """
        let holidays = try HolidaySource.nagerDate(regionCode: "US").holidays(from: Data(json.utf8))
        #expect(holidays == [Holiday(day: HolidayDay(year: 2026, month: 1, day: 1), name: "New Year's Day")])
    }

    @Test func regionsMapToTheirSources() {
        #expect(HolidaySource(regionCode: "JP") == .cabinetOfficeJapan)
        #expect(HolidaySource(regionCode: "gb") == .govUK)
        #expect(HolidaySource(regionCode: "US") == .nagerDate(regionCode: "US"))
        #expect(HolidaySource(regionCode: "ZZ") == nil)
    }

    @Test func nagerDateRequestsOneURLPerYear() {
        let urls = HolidaySource.nagerDate(regionCode: "FR").urls(for: 2025...2027)
        #expect(urls.map(\.absoluteString) == [
            "https://date.nager.at/api/v3/PublicHolidays/2025/FR",
            "https://date.nager.at/api/v3/PublicHolidays/2026/FR",
            "https://date.nager.at/api/v3/PublicHolidays/2027/FR"
        ])
    }
}
