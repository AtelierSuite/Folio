import Foundation

public struct NewReminderRequest: Sendable, Equatable {
    public var title: String
    public var dueDate: Date?
    public var listIdentifier: String?
    public var notes: String?

    public init(title: String, dueDate: Date? = nil, listIdentifier: String? = nil, notes: String? = nil) {
        self.title = title
        self.dueDate = dueDate
        self.listIdentifier = listIdentifier
        self.notes = notes
    }
}

/// The fields an edit intent changes; `nil` leaves a field as it is.
public struct ReminderChanges: Sendable, Equatable {
    public var title: String?
    public var dueDate: Date?
    public var listIdentifier: String?
    public var notes: String?

    public init(title: String? = nil, dueDate: Date? = nil, listIdentifier: String? = nil, notes: String? = nil) {
        self.title = title
        self.dueDate = dueDate
        self.listIdentifier = listIdentifier
        self.notes = notes
    }

    func applied(to draft: ReminderDraft, calendar: Calendar) -> ReminderDraft {
        var draft = draft
        if let title = title?.trimmingCharacters(in: .whitespacesAndNewlines), !title.isEmpty {
            draft.title = title
        }
        if let dueDate {
            draft.setIntentDueDate(dueDate, calendar: calendar)
        }
        if let listIdentifier {
            draft.listIdentifier = listIdentifier
        }
        if let notes {
            draft.notes = notes
        }
        return draft
    }
}

extension ReminderDraft {
    /// Siri always passes a date with a time; a time of midnight means just the day.
    mutating func setIntentDueDate(_ date: Date, calendar: Calendar) {
        dueDate = date
        hasDueTime = calendar.startOfDay(for: date) != date
    }
}
