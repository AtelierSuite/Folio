import Foundation

public struct NotificationPlanner: Sendable {
    public static let pendingLimit = 64
    public static let defaultReservedSlots = 4

    public var reservedSlots: Int
    public var formatter: NotificationContentFormatter
    public var styleResolver: @Sendable (NotificationCandidate) -> NotificationAlertStyle
    public var allDayAlertMinutes: @Sendable (String) -> Int?

    public init(
        reservedSlots: Int = defaultReservedSlots,
        formatter: NotificationContentFormatter = NotificationContentFormatter(),
        styleResolver: @escaping @Sendable (NotificationCandidate) -> NotificationAlertStyle = { _ in .standard },
        allDayAlertMinutes: @escaping @Sendable (String) -> Int? = { _ in nil }
    ) {
        self.reservedSlots = reservedSlots
        self.formatter = formatter
        self.styleResolver = styleResolver
        self.allDayAlertMinutes = allDayAlertMinutes
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
            let eventFireDates = fireDates(for: event, after: now)
            let meeting = eventFireDates.isEmpty ? nil : NotificationMeeting(event: event)
            let place = eventFireDates.isEmpty ? nil : NotificationPlace(event: event)
            return eventFireDates.map { fireDate in
                NotificationCandidate(
                    fireDate: fireDate,
                    kind: .event,
                    reference: event.reference,
                    content: formatter.content(for: event, firingAt: fireDate),
                    meeting: meeting,
                    place: place
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

    private func fireDates(for event: CalendarEvent, after now: Date) -> [Date] {
        guard event.isAllDay, let minutes = allDayAlertMinutes(event.calendarIdentifier) else {
            return fireDates(for: event.alarms, anchor: event.startDate, after: now)
        }
        let retimed = event.alarms.compactMap { alarm -> Date? in
            guard let fireDate = alarm.fireDate(relativeTo: event.startDate) else { return nil }
            guard case .relative = alarm else { return fireDate }
            let startOfDay = formatter.calendar.startOfDay(for: fireDate)
            return formatter.calendar.date(byAdding: .minute, value: minutes, to: startOfDay)
        }
        return Array(Set(retimed)).filter { $0 > now }
    }

    private func fireDates(for alarms: [CalendarAlarm], anchor: Date?, after now: Date) -> [Date] {
        alarms.compactMap { $0.fireDate(relativeTo: anchor) }.filter { $0 > now }
    }
}
