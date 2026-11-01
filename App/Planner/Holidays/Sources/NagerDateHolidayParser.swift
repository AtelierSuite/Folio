import Foundation

/// Parses Nager.Date's `PublicHolidays` response, keeping nationwide public holidays only.
enum NagerDateHolidayParser {
    private struct Entry: Decodable {
        let date: String
        let localName: String
        let global: Bool
        let types: [String]
    }

    static func holidays(from data: Data) throws -> [Holiday] {
        try JSONDecoder().decode([Entry].self, from: data).compactMap { entry in
            guard entry.global, entry.types.contains("Public") else { return nil }
            return HolidayDay(separatedDate: entry.date, separator: "-").map { Holiday(day: $0, name: entry.localName) }
        }
    }
}
