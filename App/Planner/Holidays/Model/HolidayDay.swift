import Foundation

/// A Gregorian calendar day, independent of the user's calendar system and time zone.
public struct HolidayDay: Codable, Hashable, Comparable, Sendable {
    public let year: Int
    public let month: Int
    public let day: Int

    public init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    public init(date: Date, timeZone: TimeZone) {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = timeZone
        let components = gregorian.dateComponents([.year, .month, .day], from: date)
        self.init(year: components.year ?? 0, month: components.month ?? 0, day: components.day ?? 0)
    }

    init?(separatedDate: some StringProtocol, separator: Character) {
        let parts = separatedDate.split(separator: separator).compactMap { part in
            Int(part.trimmingCharacters(in: .whitespaces))
        }
        guard parts.count == 3, (1...12).contains(parts[1]), (1...31).contains(parts[2]) else { return nil }
        self.init(year: parts[0], month: parts[1], day: parts[2])
    }

    public static func < (lhs: HolidayDay, rhs: HolidayDay) -> Bool {
        (lhs.year, lhs.month, lhs.day) < (rhs.year, rhs.month, rhs.day)
    }
}
