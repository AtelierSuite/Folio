import Foundation

public struct NotificationPlanner: Sendable {
    public static let pendingLimit = 64
    public static let defaultReservedSlots = 4

    public var reservedSlots: Int
    public var formatter: NotificationContentFormatter
    public var styleResolver: @Sendable (NotificationCandidate) -> NotificationAlertStyle

    public init(
        reservedSlots: Int = defaultReservedSlots,
        formatter: NotificationContentFormatter = NotificationContentFormatter(),
        styleResolver: @escaping @Sendable (NotificationCandidate) -> NotificationAlertStyle = { _ in .standard }
    ) {
        self.reservedSlots = reservedSlots
        self.formatter = formatter
        self.styleResolver = styleResolver
    }

    public func budget(foreignPendingCount: Int) -> Int {
        let limit = Self.pendingLimit
        return max(0, min(limit - reservedSlots, limit - foreignPendingCount))
    }

    public func plan(
        events: [CalendarEvent],
        reminders: [ReminderItem],
        after now: Date,
        budget: Int
    ) -> [PlannedNotification] {
        let candidates = eventCandidates(events, after: now) + reminderCandidates(reminders, after: now)
        var seenIdentifiers = Set<String>()
        let planned = candidates
            .map { PlannedNotification($0, style: styleResolver($0)) }
            .filter { seenIdentifiers.insert($0.id).inserted }
            .sorted { ($0.fireDate, $0.id) < ($1.fireDate, $1.id) }
        return Array(planned.prefix(max(0, budget)))
    }

    private func eventCandidates(_ events: [CalendarEvent], after now: Date) -> [NotificationCandidate] {
        events.flatMap { event in
            fireDates(for: event.alarms, anchor: event.startDate, after: now).map { fireDate in
                NotificationCandidate(
                    fireDate: fireDate,
                    kind: .event,
                    reference: event.reference,
                    content: formatter.content(for: event, firingAt: fireDate)
                )
            }
        }
    }

    private func reminderCandidates(_ reminders: [ReminderItem], after now: Date) -> [NotificationCandidate] {
        reminders.filter { !$0.isCompleted }.flatMap { reminder in
            let alarms = reminder.alarms.map(CalendarAlarm.init)
            return fireDates(for: alarms, anchor: reminder.dueDate, after: now).map { fireDate in
                NotificationCandidate(
                    fireDate: fireDate,
                    kind: .reminder,
                    reference: reminder.reference,
                    content: formatter.content(for: reminder, firingAt: fireDate)
                )
            }
        }
    }

    private func fireDates(for alarms: [CalendarAlarm], anchor: Date?, after now: Date) -> [Date] {
        alarms.compactMap { $0.fireDate(relativeTo: anchor) }.filter { $0 > now }
    }
}
