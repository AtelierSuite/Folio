import Foundation

extension Calendar {
    /// The start of the day that has the same date as `date` had in `previousCalendar`,
    /// so a selected day stays the same day when the time zone changes.
    public func startOfSameDay(as date: Date, in previousCalendar: Calendar) -> Date {
        let components = previousCalendar.dateComponents([.era, .year, .month, .day], from: date)
        guard let sameDay = self.date(from: components) else { return startOfDay(for: date) }
        return startOfDay(for: sameDay)
    }
}
