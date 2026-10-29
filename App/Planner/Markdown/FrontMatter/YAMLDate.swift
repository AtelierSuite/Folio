import Foundation

enum YAMLDate {
    static func date(from text: String) -> Date? {
        if let date = try? dateTimeStyle.parse(text) { return date }
        if let date = try? dateTimeStyle.time(includingFractionalSeconds: true).parse(text) { return date }
        return try? dayStyle.parse(text)
    }

    static func string(from date: Date) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        return calendar.startOfDay(for: date) == date ? dayStyle.format(date) : dateTimeStyle.format(date)
    }

    private static var dayStyle: Date.ISO8601FormatStyle {
        Date.ISO8601FormatStyle(timeZone: .current).year().month().day()
    }

    private static var dateTimeStyle: Date.ISO8601FormatStyle {
        Date.ISO8601FormatStyle(timeZone: .current)
    }
}
