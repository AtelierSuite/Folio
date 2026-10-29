import Foundation

extension MonthGrid {
    static let isoThursday = 5

    /// A row that doesn't start on Monday straddles two ISO weeks. The row's Thursday always
    /// sits in the ISO week that covers at least four of the row's days, so it names the row.
    static func isoWeekNumber(of days: [MonthDay], calendar: Calendar) -> Int {
        var isoCalendar = Calendar(identifier: .iso8601)
        isoCalendar.timeZone = calendar.timeZone
        let thursday = days.first { isoCalendar.component(.weekday, from: $0.date) == isoThursday }
        guard let date = thursday?.date ?? days.first?.date else { return 0 }
        return isoCalendar.component(.weekOfYear, from: noon(of: date, calendar: isoCalendar))
    }
}
