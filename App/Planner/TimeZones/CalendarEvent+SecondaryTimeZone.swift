import Foundation

extension CalendarEvent {
    /// Floating and all-day events keep their clock time everywhere, so converting them would mislead.
    public func showsTime(in secondaryTimeZone: TimeZone, comparedTo systemTimeZone: TimeZone) -> Bool {
        guard !isAllDay, timeZone != nil else { return false }
        return secondaryTimeZone.secondsFromGMT(for: startDate) != systemTimeZone.secondsFromGMT(for: startDate)
    }
}
