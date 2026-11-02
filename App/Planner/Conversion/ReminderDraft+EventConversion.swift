import Foundation

extension ReminderDraft {
    /// The reminder as an event starting when it's due and lasting `EventDraft.defaultDuration`.
    /// A reminder with no due time becomes an all-day event, and one with no due date one on `today`.
    public func convertedToEvent(
        calendarIdentifier: String,
        today: Date = .now,
        calendar: Calendar = .current
    ) -> EventDraft {
        let isAllDay = dueDate == nil || !hasDueTime
        let startDate = isAllDay ? calendar.startOfDay(for: dueDate ?? today) : (dueDate ?? today)
        let endDate = isAllDay
            ? calendar.date(byAdding: .day, value: 1, to: startDate) ?? startDate
            : startDate.addingTimeInterval(EventDraft.defaultDuration)
        return EventDraft(
            title: title,
            calendarIdentifier: calendarIdentifier,
            startDate: startDate,
            endDate: endDate,
            isAllDay: isAllDay,
            timeZone: isAllDay ? nil : calendar.timeZone,
            recurrence: dueDate == nil ? nil : recurrence.map(\.eventRecurrence),
            alerts: eventAlerts(startingAt: startDate),
            url: url,
            notes: notes
        )
    }

    private func eventAlerts(startingAt startDate: Date) -> [EventAlert] {
        alarms.reduce(into: []) { alerts, alarm in
            let offset = switch alarm {
            case .relative(let offset): offset
            case .absolute(let date): date.timeIntervalSince(startDate)
            }
            let alert = EventAlert(offset: offset)
            if !alerts.contains(alert) {
                alerts.append(alert)
            }
        }
    }
}

extension ReminderRecurrence {
    var eventRecurrence: EventRecurrence {
        EventRecurrence(
            frequency: EventRecurrence.Frequency(rawValue: frequency.rawValue) ?? .daily,
            interval: interval,
            end: endDate.map { .onDate($0) } ?? .never
        )
    }
}
