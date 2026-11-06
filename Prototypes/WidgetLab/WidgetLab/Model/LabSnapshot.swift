import Foundation

struct LabSnapshot {
    var now: Date
    var events: [LabEvent] = []
    var reminders: [LabReminder] = []
    var doses: [LabDose] = []
    var lastSleep: DateInterval?
    var wakeUpAlarm: Date?
    var weather: [LabWeather] = []
    var rainyHours: [ClosedRange<Date>] = []
    var holidays: [LabHoliday] = []
    var calendar = LabClock.calendar

    var startOfToday: Date { calendar.startOfDay(for: now) }

    var eventsToday: [LabEvent] { events(on: now) }

    func events(on day: Date) -> [LabEvent] {
        events.filter { calendar.isDate($0.start, inSameDayAs: day) }
    }

    func weather(on day: Date) -> LabWeather? {
        weather.first { calendar.isDate($0.date, inSameDayAs: day) }
    }

    func holiday(on day: Date) -> LabHoliday? {
        holidays.first { calendar.isDate($0.date, inSameDayAs: day) }
    }

    func isRaining(at date: Date) -> Bool {
        rainyHours.contains { $0.contains(date) }
    }
}
