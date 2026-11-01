import Foundation

/// Parses GOV.UK's `bank-holidays.json`, using the England and Wales division.
enum GovUKHolidayParser {
    static func holidays(from data: Data) throws -> [Holiday] {
        try JSONDecoder().decode(GovUKBankHolidays.self, from: data).englandAndWales.events.compactMap { event in
            HolidayDay(separatedDate: event.date, separator: "-").map { Holiday(day: $0, name: event.title) }
        }
    }
}

private struct GovUKBankHolidays: Decodable {
    let englandAndWales: GovUKDivision

    enum CodingKeys: String, CodingKey {
        case englandAndWales = "england-and-wales"
    }
}

private struct GovUKDivision: Decodable {
    let events: [GovUKBankHoliday]
}

private struct GovUKBankHoliday: Decodable {
    let title: String
    let date: String
}
