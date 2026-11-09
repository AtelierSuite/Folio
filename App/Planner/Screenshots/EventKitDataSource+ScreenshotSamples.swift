#if DEBUG && !os(watchOS)
import EventKit

extension EventKitDataSource {
    /// Replaces the calendars any earlier run made with the samples', and returns their identifiers by sample key.
    /// With `removesOtherCalendars`, as on a screenshot simulator, every other calendar that can be removed goes too.
    /// The countdown's event is only added where a countdown can run, as it would crowd the calendar elsewhere.
    public func seedScreenshotSamples(
        _ samples: ScreenshotSamples,
        removesOtherCalendars: Bool,
        includesCountdown: Bool,
        now: Date = .now,
        calendar: Calendar = .current
    ) async throws -> [String: String] {
        for kind in CalendarItemKind.allCases where !authorizationStatus(for: kind).allowsReading {
            _ = try await requestFullAccess(to: kind)
        }
        var identifiers: [String: EKCalendar] = [:]
        for sample in samples.calendars {
            identifiers[sample.key] = try makeCalendar(sample)
        }
        let made = Set(identifiers.values.map(\.calendarIdentifier))
        removeCalendars(sparing: made, keepingOthers: !removesOtherCalendars)
        let monday = ScreenshotSamples.monday(ofWeekContaining: now, calendar: calendar)
        try saveEvents(samples.events, calendars: identifiers, from: monday, calendar: calendar)
        let today = calendar.startOfDay(for: now)
        try saveReminders(samples.reminders, lists: identifiers, from: today, calendar: calendar)
        if includesCountdown, let countdownCalendar = identifiers[samples.countdown.calendar] {
            try saveCountdown(samples.countdown, into: countdownCalendar, now: now)
        }
        try eventStore.commit()
        return identifiers.mapValues(\.calendarIdentifier)
    }

    private func removeCalendars(sparing made: Set<String>, keepingOthers: Bool) {
        let sampleTitles = ScreenshotSamples.allCalendarTitles
        for kind in CalendarItemKind.allCases {
            for existing in eventStore.calendars(for: kind.entityType)
            where !made.contains(existing.calendarIdentifier)
                && (keepingOthers ? sampleTitles.contains(existing.title) : existing.type != .birthday) {
                try? eventStore.removeCalendar(existing, commit: false)
            }
        }
    }

    private func makeCalendar(_ sample: ScreenshotSamples.SampleCalendar) throws -> EKCalendar {
        let defaultCalendar = sample.kind == .event
            ? eventStore.defaultCalendarForNewEvents
            : eventStore.defaultCalendarForNewReminders()
        let source = eventStore.sources.first { $0.sourceType == .local }
            ?? defaultCalendar?.source
            ?? eventStore.sources.first
        let made = EKCalendar(for: sample.kind.entityType, eventStore: eventStore)
        made.title = sample.title
        made.source = source
        made.cgColor = CGColor(
            srgbRed: CGFloat((sample.colorHex >> 16) & 0xFF) / 255,
            green: CGFloat((sample.colorHex >> 8) & 0xFF) / 255,
            blue: CGFloat(sample.colorHex & 0xFF) / 255,
            alpha: 1
        )
        try eventStore.saveCalendar(made, commit: false)
        return made
    }

    /// The week's events, repeated the week after, so a run late in the week still has a full next weekday.
    private func saveEvents(
        _ samples: [ScreenshotSamples.SampleEvent],
        calendars: [String: EKCalendar],
        from monday: Date,
        calendar: Calendar
    ) throws {
        for weekOffset in [0, 7] {
            for sample in samples {
                guard let eventCalendar = calendars[sample.calendar],
                      let day = calendar.date(byAdding: .day, value: sample.day + weekOffset, to: monday),
                      let start = calendar.date(bySettingHour: sample.hour, minute: sample.minute, second: 0, of: day)
                else { continue }
                let event = EKEvent(eventStore: eventStore)
                event.calendar = eventCalendar
                event.title = sample.title
                event.location = sample.location
                event.isAllDay = sample.isAllDay
                event.startDate = start
                event.endDate = sample.isAllDay ? start : start.addingTimeInterval(sample.hours * 3600)
                for minutes in sample.alarmMinutes {
                    event.addAlarm(EKAlarm(relativeOffset: TimeInterval(minutes * 60)))
                }
                try eventStore.save(event, span: .thisEvent, commit: false)
            }
        }
    }

    private func saveReminders(
        _ samples: [ScreenshotSamples.SampleReminder],
        lists: [String: EKCalendar],
        from today: Date,
        calendar: Calendar
    ) throws {
        for sample in samples {
            guard let list = lists[sample.list] else { continue }
            let reminder = EKReminder(eventStore: eventStore)
            reminder.calendar = list
            reminder.title = sample.title
            reminder.notes = sample.notes
            if let dayOffset = sample.day, let day = calendar.date(byAdding: .day, value: dayOffset, to: today) {
                var components = calendar.dateComponents([.year, .month, .day], from: day)
                components.hour = sample.hour
                components.minute = sample.hour == nil ? nil : 0
                reminder.dueDateComponents = components
            }
            reminder.isCompleted = sample.isCompleted
            try eventStore.save(reminder, commit: false)
        }
    }

    private func saveCountdown(
        _ sample: ScreenshotSamples.SampleCountdown, into eventCalendar: EKCalendar, now: Date
    ) throws {
        let event = EKEvent(eventStore: eventStore)
        event.calendar = eventCalendar
        event.title = sample.title
        event.location = sample.location
        let wholeMinute = (now.timeIntervalSinceReferenceDate / 60).rounded(.down) * 60
        event.startDate = Date(timeIntervalSinceReferenceDate: wholeMinute + TimeInterval(sample.startsInMinutes * 60))
        event.endDate = event.startDate.addingTimeInterval(3600)
        try eventStore.save(event, span: .thisEvent, commit: false)
    }
}
#endif
