import Foundation

extension EventDraft {
    /// The event as a reminder due when it starts. Reminders have no end, so the end time is dropped,
    /// and the location is kept as a line in the notes.
    public func convertedToReminder(listIdentifier: String, calendar: Calendar = .current) -> ReminderDraft {
        ReminderDraft(
            title: title,
            listIdentifier: listIdentifier,
            dueDate: isAllDay ? calendar.startOfDay(for: startDate) : startDate,
            hasDueTime: !isAllDay,
            recurrence: recurrence.map { $0.reminderRecurrence(startingOn: startDate, calendar: calendar) },
            alarms: alerts.map { alert in
                isAllDay ? .absolute(startDate.addingTimeInterval(alert.offset)) : .relative(alert.offset)
            },
            url: url,
            notes: notesIncludingLocation
        )
    }

    private var notesIncludingLocation: String {
        [location?.text, notes]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: "\n\n")
    }
}

extension EventRecurrence {
    func reminderRecurrence(startingOn startDate: Date, calendar: Calendar) -> ReminderRecurrence {
        let endDate: Date? = switch end {
        case .never: nil
        case .onDate(let date): date
        case .afterOccurrences(let count): lastOccurrence(after: count, from: startDate, calendar: calendar)
        }
        return ReminderRecurrence(
            frequency: ReminderRecurrence.Frequency(rawValue: frequency.rawValue) ?? .daily,
            interval: interval,
            endDate: endDate
        )
    }

    private func lastOccurrence(after count: Int, from startDate: Date, calendar: Calendar) -> Date? {
        let component: Calendar.Component = switch frequency {
        case .daily: .day
        case .weekly: .weekOfYear
        case .monthly: .month
        case .yearly: .year
        }
        return calendar.date(byAdding: component, value: interval * max(count - 1, 0), to: startDate)
    }
}
