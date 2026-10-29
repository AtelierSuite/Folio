import Foundation

extension TimelineDays {
    /// One column per date, in the given order. The dates don't need to be consecutive,
    /// so a working week can skip days (Mon, Tue, Thu).
    public init(dates: [Date], calendar: Calendar) {
        let intervals = dates.compactMap { date in
            calendar.dateInterval(of: .day, for: date)
        }
        self.init(intervals: intervals, calendar: calendar)
    }
}
