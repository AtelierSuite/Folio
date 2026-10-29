import Foundation

public struct AgendaBriefingLoader: Sendable {
    static let upNextHorizon: TimeInterval = 7 * 86_400
    static let followingLimit = 2

    private let events: EventLookup
    private let reminders: ReminderLookup
    private let calendar: Calendar

    public init(
        source: any CalendarDataSource = EventKitDataSource.shared,
        visibilityStorage: CalendarVisibilityStorage = CalendarVisibilityStorage(),
        calendar: Calendar = .current
    ) {
        events = EventLookup(source: source, visibilityStorage: visibilityStorage, calendar: calendar)
        reminders = ReminderLookup(source: source, visibilityStorage: visibilityStorage)
        self.calendar = calendar
    }

    /// The ongoing or next timed event this week, and the couple after it.
    public func upNext(at now: Date = .now) async -> AgendaBriefing {
        let upcoming = await events.visibleEvents(in: DateInterval(start: now, duration: Self.upNextHorizon))
            .filter { !$0.isAllDay && $0.endDate > now }
        guard let next = upcoming.first else {
            return AgendaBriefing(events: [], dialog: AgendaDialogText.nothingNext())
        }
        return AgendaBriefing(
            events: Array(upcoming.prefix(1 + Self.followingLimit)),
            dialog: AgendaDialogText.upNext(next, now: now, calendar: calendar)
        )
    }

    /// Everything on today's calendar, with the open reminders due today.
    public func today(at now: Date = .now) async -> AgendaBriefing {
        guard let day = calendar.dateInterval(of: .day, for: now) else {
            return AgendaBriefing(events: [], dialog: AgendaDialogText.todayClear())
        }
        let todayEvents = await events.visibleEvents(in: day)
        let dueReminders = await reminders.visibleReminders(now: now)
            .filter { !$0.isCompleted && $0.isDue(in: day) }
        return AgendaBriefing(
            events: todayEvents,
            reminders: dueReminders,
            dialog: AgendaDialogText.today(events: todayEvents, reminders: dueReminders, now: now, calendar: calendar)
        )
    }

    /// The meeting with a link that starts or started closest to now, among those not yet over.
    public func nextMeeting(at now: Date = .now) async -> CalendarEvent? {
        await events.visibleEvents(in: DateInterval(start: now, duration: Self.upNextHorizon))
            .filter { !$0.isAllDay && $0.endDate > now && IntentMeetingLink.url(for: $0) != nil }
            .min { abs($0.startDate.timeIntervalSince(now)) < abs($1.startDate.timeIntervalSince(now)) }
    }
}
