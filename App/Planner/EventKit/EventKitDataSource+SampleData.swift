#if DEBUG
import EventKit

extension EventKitDataSource {
    public static let sampleDataLaunchArgument = "-SeedSampleCalendarData"
    static let sampleCalendarTitle = "Folio Samples"

    public func seedSampleData(calendar: Calendar = .current) async throws {
        if !authorizationStatus(for: .event).allowsReading {
            _ = try await requestFullAccess(to: .event)
        }
        if !authorizationStatus(for: .reminder).allowsReading {
            _ = try await requestFullAccess(to: .reminder)
        }
        let today = calendar.startOfDay(for: .now)
        if let eventCalendar = try makeSampleCalendar(for: .event) {
            try seedSampleEvents(into: eventCalendar, from: today, calendar: calendar)
        }
        if let reminderList = try makeSampleCalendar(for: .reminder) {
            try seedSampleReminders(into: reminderList, from: today, calendar: calendar)
        }
        try eventStore.commit()
    }

    private func makeSampleCalendar(for kind: CalendarItemKind) throws -> EKCalendar? {
        for existing in eventStore.calendars(for: kind.entityType) where existing.title == Self.sampleCalendarTitle {
            try eventStore.removeCalendar(existing, commit: false)
        }
        let defaultCalendar = kind == .event
            ? eventStore.defaultCalendarForNewEvents
            : eventStore.defaultCalendarForNewReminders()
        guard let source = defaultCalendar?.source
            ?? eventStore.sources.first(where: { $0.sourceType == .local }) else { return nil }
        let sampleCalendar = EKCalendar(for: kind.entityType, eventStore: eventStore)
        sampleCalendar.title = Self.sampleCalendarTitle
        sampleCalendar.source = source
        sampleCalendar.cgColor = kind == .event
            ? CGColor(srgbRed: 0.35, green: 0.47, blue: 0.95, alpha: 1)
            : CGColor(srgbRed: 0.96, green: 0.55, blue: 0.2, alpha: 1)
        try eventStore.saveCalendar(sampleCalendar, commit: false)
        return sampleCalendar
    }

    private func seedSampleEvents(into eventCalendar: EKCalendar, from today: Date, calendar: Calendar) throws {
        let samples = [
            SampleEvent(title: "Standup", day: 0, hour: 9, minute: 0, hours: 0.25),
            SampleEvent(title: "Lunch with Aiko", day: 0, hour: 12, minute: 30, hours: 1),
            SampleEvent(title: "Design Review Day", day: 1, hour: 0, minute: 0, hours: 24, isAllDay: true),
            SampleEvent(title: "Dentist", day: 2, hour: 15, minute: 0, hours: 1),
            SampleEvent(title: "Team Offsite", day: 3, hour: 10, minute: 0, hours: 6),
            SampleEvent(title: "Concert", day: 5, hour: 19, minute: 0, hours: 2.5)
        ]
        for sample in samples {
            let event = EKEvent(eventStore: eventStore)
            event.calendar = eventCalendar
            event.title = sample.title
            let day = calendar.date(byAdding: .day, value: sample.day, to: today) ?? today
            let start = calendar.date(bySettingHour: sample.hour, minute: sample.minute, second: 0, of: day) ?? day
            event.startDate = start
            event.endDate = start.addingTimeInterval(sample.hours * 3600)
            event.isAllDay = sample.isAllDay
            if sample.title == "Standup" {
                event.addRecurrenceRule(EKRecurrenceRule(recurrenceWith: .daily, interval: 1, end: nil))
            }
            try eventStore.save(event, span: .futureEvents, commit: false)
        }
    }

    private func seedSampleReminders(into reminderList: EKCalendar, from today: Date, calendar: Calendar) throws {
        let samples = [
            SampleReminder(title: "Buy groceries", day: 0, hour: 17),
            SampleReminder(title: "Send invoice", day: 1, hour: nil),
            SampleReminder(title: "Call the plumber", day: 3, hour: 10)
        ]
        for sample in samples {
            let reminder = EKReminder(eventStore: eventStore)
            reminder.calendar = reminderList
            reminder.title = sample.title
            let day = calendar.date(byAdding: .day, value: sample.day, to: today) ?? today
            var components = calendar.dateComponents([.year, .month, .day], from: day)
            components.hour = sample.hour
            components.minute = sample.hour == nil ? nil : 0
            reminder.dueDateComponents = components
            try eventStore.save(reminder, commit: false)
        }
    }
}

private struct SampleEvent {
    let title: String
    let day: Int
    let hour: Int
    let minute: Int
    let hours: Double
    var isAllDay = false
}

private struct SampleReminder {
    let title: String
    let day: Int
    let hour: Int?
}
#endif
