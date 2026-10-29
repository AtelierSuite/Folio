import AppIntents
import Foundation

public struct EventEntity: AppEntity, Identifiable, Sendable {
    public static let typeDisplayRepresentation = TypeDisplayRepresentation(
        name: LocalizedStringResource("EventEntity.TypeName", table: "AppIntents", bundle: #bundle)
    )
    public static let defaultQuery = EventEntityQuery()

    /// The event's `CalendarItemReference.storageKey`, which survives sync and identifies one occurrence.
    public let id: String
    public let reference: CalendarItemReference
    public let calendarIdentifier: String
    public let isReadOnly: Bool
    public let isRecurring: Bool

    @Property(title: LocalizedStringResource("EventEntity.Title", table: "AppIntents", bundle: #bundle))
    public var title: String

    @Property(title: LocalizedStringResource("EventEntity.StartDate", table: "AppIntents", bundle: #bundle))
    public var startDate: Date

    @Property(title: LocalizedStringResource("EventEntity.EndDate", table: "AppIntents", bundle: #bundle))
    public var endDate: Date

    @Property(title: LocalizedStringResource("EventEntity.IsAllDay", table: "AppIntents", bundle: #bundle))
    public var isAllDay: Bool

    @Property(title: LocalizedStringResource("EventEntity.Location", table: "AppIntents", bundle: #bundle))
    public var location: String?

    @Property(title: LocalizedStringResource("EventEntity.Notes", table: "AppIntents", bundle: #bundle))
    public var notes: String?

    @Property(title: LocalizedStringResource("EventEntity.MeetingLink", table: "AppIntents", bundle: #bundle))
    public var meetingLink: URL?

    public init(_ event: CalendarEvent) {
        id = event.reference.storageKey
        reference = event.reference
        calendarIdentifier = event.calendarIdentifier
        isReadOnly = event.isReadOnly
        isRecurring = event.isRecurring
        title = event.title
        startDate = event.startDate
        endDate = event.endDate
        isAllDay = event.isAllDay
        location = event.location
        notes = event.notes
        meetingLink = MeetingLink.joinURL(in: [event.location, event.notes], url: event.url)
    }

    public var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(title)",
            subtitle: "\(IntentDateText.timeRange(from: startDate, to: endDate, isAllDay: isAllDay))",
            image: DisplayRepresentation.Image(systemName: "calendar")
        )
    }
}
