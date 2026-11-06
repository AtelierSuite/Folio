import Foundation
import SwiftUI

struct HorizonItem: Identifiable {
    var title: String
    var date: Date
    var tint: Color
    var daysAway: Int
    var id: String { "\(title)-\(daysAway)" }
}

struct LongWeekend: Equatable {
    var start: Date
    var end: Date
}

enum HorizonScale {
    static let maximumDays = 365.0
    static let marks: [(label: String, days: Double)] = [("1w", 7), ("1m", 30), ("3m", 91), ("1y", 365)]

    static func position(daysAway: Double) -> Double {
        min(log(1 + max(daysAway, 0)) / log(1 + maximumDays), 1)
    }

    static func items(in snapshot: LabSnapshot) -> [HorizonItem] {
        let events = snapshot.events
            .filter { $0.isAllDay && $0.start > snapshot.now }
            .map { item(title: $0.title, date: $0.start, tint: $0.tint, in: snapshot) }
        let holidays = snapshot.holidays
            .filter { $0.date > snapshot.now }
            .map { item(title: $0.name, date: $0.date, tint: .red, in: snapshot) }
        return (events + holidays).sorted { $0.daysAway < $1.daysAway }
    }

    /// A holiday touching a weekend, walked outwards to take in the whole run of days off.
    static func nextLongWeekend(in snapshot: LabSnapshot) -> LongWeekend? {
        let calendar = snapshot.calendar
        for holiday in snapshot.holidays.sorted(by: { $0.date < $1.date }) where holiday.date > snapshot.now {
            var start = calendar.startOfDay(for: holiday.date)
            var end = start
            while let previous = calendar.date(byAdding: .day, value: -1, to: start), isDayOff(previous, in: snapshot) {
                start = previous
            }
            while let next = calendar.date(byAdding: .day, value: 1, to: end), isDayOff(next, in: snapshot) {
                end = next
            }
            if end > start, !calendar.isDateInWeekend(holiday.date) {
                return LongWeekend(start: start, end: end)
            }
        }
        return nil
    }

    private static func isDayOff(_ date: Date, in snapshot: LabSnapshot) -> Bool {
        snapshot.calendar.isDateInWeekend(date) || snapshot.holiday(on: date) != nil
    }

    private static func item(title: String, date: Date, tint: Color, in snapshot: LabSnapshot) -> HorizonItem {
        let days = snapshot.calendar.dateComponents([.day], from: snapshot.startOfToday, to: date).day ?? 0
        return HorizonItem(title: title, date: date, tint: tint, daysAway: days)
    }
}
