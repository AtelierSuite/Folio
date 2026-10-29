import Foundation

extension ReminderDraft {
    public func normalized() -> ReminderDraft {
        var draft = self
        draft.title = trimmedTitle
        draft.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        if dueDate == nil {
            draft.hasDueTime = false
            draft.recurrence = nil
        }
        if !draft.canUseRelativeAlarms {
            draft.alarms.removeAll(where: \.isRelative)
        }
        draft.alarms = draft.alarms.reduce(into: []) { unique, alarm in
            if !unique.contains(alarm) {
                unique.append(alarm)
            }
        }
        return draft
    }

    public func dueDateComponents(in calendar: Calendar = .current) -> DateComponents? {
        guard let dueDate else { return nil }
        let units: Set<Calendar.Component> = hasDueTime
            ? [.year, .month, .day, .hour, .minute]
            : [.year, .month, .day]
        return calendar.dateComponents(units, from: dueDate)
    }

    public static func parsedURL(from text: String) -> URL? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        if let url = URL(string: trimmed), url.scheme != nil {
            return url
        }
        return URL(string: "https://\(trimmed)")
    }
}
