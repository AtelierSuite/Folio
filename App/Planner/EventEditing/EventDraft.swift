import Foundation

public struct EventDraft: Sendable, Hashable {
    public var title: String
    public var calendarIdentifier: String
    public var startDate: Date
    public var endDate: Date
    public var isAllDay: Bool
    public var timeZone: TimeZone?
    public var recurrence: EventRecurrence?
    public var alerts: [EventAlert]
    public var location: EventLocation?
    public var url: URL?
    public var notes: String

    public init(
        title: String = "",
        calendarIdentifier: String,
        startDate: Date,
        endDate: Date,
        isAllDay: Bool = false,
        timeZone: TimeZone? = .current,
        recurrence: EventRecurrence? = nil,
        alerts: [EventAlert] = [],
        location: EventLocation? = nil,
        url: URL? = nil,
        notes: String = ""
    ) {
        self.title = title
        self.calendarIdentifier = calendarIdentifier
        self.startDate = startDate
        self.endDate = endDate
        self.isAllDay = isAllDay
        self.timeZone = timeZone
        self.recurrence = recurrence
        self.alerts = alerts
        self.location = location
        self.url = url
        self.notes = notes
    }

    public var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }

    public var hasValidDates: Bool {
        endDate >= startDate
    }

    public var savedTimeZone: TimeZone? {
        isAllDay ? nil : (timeZone ?? .current)
    }
}
