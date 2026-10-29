import Foundation

public struct NewEventRequest: Sendable, Equatable {
    public var title: String
    public var startDate: Date
    public var endDate: Date?
    public var isAllDay: Bool
    public var calendarIdentifier: String?
    public var location: String?
    public var notes: String?

    public init(
        title: String,
        startDate: Date,
        endDate: Date? = nil,
        isAllDay: Bool = false,
        calendarIdentifier: String? = nil,
        location: String? = nil,
        notes: String? = nil
    ) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.isAllDay = isAllDay
        self.calendarIdentifier = calendarIdentifier
        self.location = location
        self.notes = notes
    }
}

/// The fields an edit intent changes; `nil` leaves a field as it is.
public struct EventChanges: Sendable, Equatable {
    public var title: String?
    public var startDate: Date?
    public var endDate: Date?
    public var calendarIdentifier: String?
    public var location: String?
    public var notes: String?

    public init(
        title: String? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        calendarIdentifier: String? = nil,
        location: String? = nil,
        notes: String? = nil
    ) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.calendarIdentifier = calendarIdentifier
        self.location = location
        self.notes = notes
    }

    func applied(to draft: EventDraft) -> EventDraft {
        var draft = draft
        if let title = title?.trimmingCharacters(in: .whitespacesAndNewlines), !title.isEmpty {
            draft.title = title
        }
        if let startDate {
            draft.moveStart(to: startDate)
        }
        if let endDate {
            draft.endDate = endDate
        }
        if let calendarIdentifier {
            draft.calendarIdentifier = calendarIdentifier
        }
        if let location {
            draft.location = EventLocation(text: location)
        }
        if let notes {
            draft.notes = notes
        }
        return draft
    }
}
