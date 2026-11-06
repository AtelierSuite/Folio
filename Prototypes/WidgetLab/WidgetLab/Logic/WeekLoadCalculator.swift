import Foundation

struct DayLoad: Identifiable {
    var date: Date
    var busyMinutes: Int
    var eventCount: Int
    var weather: LabWeather?
    var holiday: LabHoliday?
    var isWeekend: Bool

    var id: Date { date }
    var isDayOff: Bool { isWeekend || holiday != nil }
}

enum WeekLoadCalculator {
    static let fullDayMinutes = 480.0

    static func days(in snapshot: LabSnapshot, count: Int = 7) -> [DayLoad] {
        (0..<count).compactMap { offset in
            guard let date = snapshot.calendar.date(byAdding: .day, value: offset, to: snapshot.startOfToday) else {
                return nil
            }
            let events = snapshot.events(on: date)
            let window = FreeGapFinder.window(on: date, calendar: snapshot.calendar)
            let busy = FreeGapFinder.busyIntervals(events, in: window).reduce(0) { $0 + $1.duration }
            return DayLoad(
                date: date,
                busyMinutes: Int(busy / 60),
                eventCount: events.count,
                weather: snapshot.weather(on: date),
                holiday: snapshot.holiday(on: date),
                isWeekend: snapshot.calendar.isDateInWeekend(date)
            )
        }
    }

    static func loadFraction(_ day: DayLoad) -> Double {
        min(Double(day.busyMinutes) / fullDayMinutes, 1)
    }
}
