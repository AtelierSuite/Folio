import Foundation

public struct CalendarEvent: Identifiable, Sendable, Hashable {
    public let reference: CalendarItemReference
    public let calendarIdentifier: String
    public let title: String
    public let location: String?
    public let coordinate: PlannerCoordinate?
    public let notes: String?
    public let url: URL?
    public let startDate: Date
    public let endDate: Date
    public let isAllDay: Bool
    public let timeZone: TimeZone?
    public let color: PlannerColor
    public let isRecurring: Bool
    public let hasAttendees: Bool
    public let isReadOnly: Bool
    public let alarms: [CalendarAlarm]
    public let organizer: EventParticipant?
    public let attendees: [EventParticipant]
    /// The current user's response, or `nil` when they aren't an invitee (their own event or no attendees).
    public let userStatus: ParticipantStatus?

    public init(
        reference: CalendarItemReference,
        calendarIdentifier: String,
        title: String,
        location: String? = nil,
        coordinate: PlannerCoordinate? = nil,
        notes: String? = nil,
        url: URL? = nil,
        startDate: Date,
        endDate: Date,
        isAllDay: Bool = false,
        timeZone: TimeZone? = nil,
        color: PlannerColor = .gray,
        isRecurring: Bool = false,
        hasAttendees: Bool = false,
        isReadOnly: Bool = false,
        alarms: [CalendarAlarm] = [],
        organizer: EventParticipant? = nil,
        attendees: [EventParticipant] = [],
        userStatus: ParticipantStatus? = nil
    ) {
        self.reference = reference
        self.calendarIdentifier = calendarIdentifier
        self.title = title
        self.location = location
        self.coordinate = coordinate
        self.notes = notes
        self.url = url
        self.startDate = startDate
        self.endDate = endDate
        self.isAllDay = isAllDay
        self.timeZone = timeZone
        self.color = color
        self.isRecurring = isRecurring
        self.hasAttendees = hasAttendees
        self.isReadOnly = isReadOnly
        self.alarms = alarms
        self.organizer = organizer
        self.attendees = attendees
        self.userStatus = userStatus
    }

    public var id: String {
        "\(reference.localIdentifier)@\(startDate.timeIntervalSinceReferenceDate)"
    }

    public func overlaps(_ interval: DateInterval) -> Bool {
        if startDate == endDate {
            return interval.start <= startDate && startDate < interval.end
        }
        return startDate < interval.end && endDate > interval.start
    }
}
