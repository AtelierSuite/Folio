import Foundation

public enum WidgetDayPhase: Sendable, Equatable {
    case morning
    case daytime
    case evening

    public static let daytimeStartHour = 11
    public static let eveningStartHour = 18

    public init(at date: Date, calendar: Calendar) {
        switch calendar.component(.hour, from: date) {
        case ..<Self.daytimeStartHour: self = .morning
        case ..<Self.eveningStartHour: self = .daytime
        default: self = .evening
        }
    }

    public static func boundaries(on day: Date, calendar: Calendar) -> [Date] {
        [daytimeStartHour, eveningStartHour].compactMap {
            calendar.date(bySettingHour: $0, minute: 0, second: 0, of: day)
        }
    }
}

/// What the day needs right now: the morning's first event, what's next, or in the evening, tomorrow.
public struct WidgetDayShift: Sendable, Equatable {
    public let phase: WidgetDayPhase
    public let weather: DailyWeather?
    public let primaryEvent: CalendarEvent?
    public let laterEvents: [CalendarEvent]
    public let remainingCount: Int
    public let alarmDate: Date?
}

extension WidgetSnapshot {
    public func dayShift(at date: Date, calendar: Calendar, laterLimit: Int = 2) -> WidgetDayShift {
        let phase = WidgetDayPhase(at: date, calendar: calendar)
        let today = calendar.startOfDay(for: date)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today.addingTimeInterval(86_400)
        let remaining = activeEvents(on: today, calendar: calendar).filter { $0.endDate > date }
        let upcoming = remaining.filter { $0.startDate > date }
        let isEvening = phase == .evening
        let shown = isEvening ? activeEvents(on: tomorrow, calendar: calendar) : remaining
        return WidgetDayShift(
            phase: phase,
            weather: weather(on: isEvening ? tomorrow : today, calendar: calendar),
            primaryEvent: shown.first,
            laterEvents: isEvening ? [] : Array(shown.dropFirst().prefix(laterLimit)),
            remainingCount: upcoming.count,
            alarmDate: isEvening ? alarmDates.first { calendar.isDate($0, inSameDayAs: tomorrow) } : nil
        )
    }

    private func activeEvents(on day: Date, calendar: Calendar) -> [CalendarEvent] {
        events.filter { !$0.isAllDay && !$0.isDeclined && calendar.isDate($0.startDate, inSameDayAs: day) }
    }
}
