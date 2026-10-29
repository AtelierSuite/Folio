import Foundation

extension CalendarStore {
    /// Finds the event a deep link or intent refers to among the events on the day it starts.
    public func event(matching reference: CalendarItemReference, on date: Date, calendar: Calendar = .current) async -> CalendarEvent? {
        guard let day = calendar.dateInterval(of: .day, for: date) else { return nil }
        let candidates = await events(in: day)
        guard let match = reference.bestMatch(in: candidates.map(\.reference)) else { return nil }
        return candidates.first { $0.reference == match }
    }
}
