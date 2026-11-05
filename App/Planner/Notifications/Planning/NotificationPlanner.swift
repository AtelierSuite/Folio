import Foundation

public struct NotificationPlanner: Sendable {
    public static let pendingLimit = 64
    public static let defaultReservedSlots = 4

    public var reservedSlots: Int
    public var formatter: NotificationContentFormatter
    public var styleResolver: @Sendable (NotificationCandidate) -> NotificationAlertStyle
    public var allDayAlertMinutes: @Sendable (String) -> Int?
    public var soundResolver: @Sendable (NotificationCandidate) -> NotificationSound
    public var reminderEarlyAlerts: @Sendable (CalendarItemReference) -> [ReminderEarlyAlert]

    public init(
        reservedSlots: Int = defaultReservedSlots,
        formatter: NotificationContentFormatter = NotificationContentFormatter(),
        styleResolver: @escaping @Sendable (NotificationCandidate) -> NotificationAlertStyle = { _ in .standard },
        allDayAlertMinutes: @escaping @Sendable (String) -> Int? = { _ in nil },
        soundResolver: @escaping @Sendable (NotificationCandidate) -> NotificationSound = { _ in .system },
        reminderEarlyAlerts: @escaping @Sendable (CalendarItemReference) -> [ReminderEarlyAlert] = { _ in [] }
    ) {
        self.reservedSlots = reservedSlots
        self.formatter = formatter
        self.styleResolver = styleResolver
        self.allDayAlertMinutes = allDayAlertMinutes
        self.soundResolver = soundResolver
        self.reminderEarlyAlerts = reminderEarlyAlerts
    }

    public func budget(foreignPendingCount: Int) -> Int {
        let limit = Self.pendingLimit
        return max(0, min(limit - reservedSlots, limit - foreignPendingCount))
    }

    public func plan(
        events: [CalendarEvent],
        reminders: [ReminderItem],
        after now: Date,
        budget: Int,
        eventImages: [CalendarItemReference: URL] = [:]
    ) -> [PlannedNotification] {
        let planned = (eventNotifications(events, after: now, images: eventImages)
            + reminderNotifications(reminders, after: now))
            .sorted { ($0.fireDate, $0.id) < ($1.fireDate, $1.id) }
        return Array(planned.prefix(max(0, budget)))
    }

    func eventCandidates(
        _ events: [CalendarEvent],
        after now: Date,
        images: [CalendarItemReference: URL]
    ) -> [NotificationCandidate] {
        events.flatMap { event in
            let eventFireDates = fireDates(for: event, after: now)
            let meeting = eventFireDates.isEmpty ? nil : NotificationMeeting(event: event)
            let place = eventFireDates.isEmpty ? nil : NotificationPlace(event: event)
            return eventFireDates.map { fireDate in
                NotificationCandidate(
                    fireDate: fireDate,
                    endDate: event.endDate,
                    kind: .event,
                    reference: event.reference,
                    content: formatter.content(for: event, firingAt: fireDate),
                    meeting: meeting,
                    place: place,
                    color: event.color,
                    imageURL: images[event.reference]
                )
            }
        }
    }

    func reminderCandidates(_ reminders: [ReminderItem], after now: Date) -> [NotificationCandidate] {
        reminders.filter { !$0.isCompleted }.flatMap { reminder in
            let alarms = reminder.alarms.map(CalendarAlarm.init)
            let alarmFireDates = fireDates(for: alarms, anchor: reminder.dueDate, after: now)
            return (alarmFireDates + earlyAlertFireDates(for: reminder, after: now)).map { fireDate in
                NotificationCandidate(
                    fireDate: fireDate,
                    kind: .reminder,
                    reference: reminder.reference,
                    content: formatter.content(for: reminder, firingAt: fireDate),
                    color: reminder.color
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
