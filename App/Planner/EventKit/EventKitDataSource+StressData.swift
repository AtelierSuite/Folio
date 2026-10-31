#if DEBUG
import EventKit

extension EventKitDataSource {
    public static let stressDataLaunchArgument = "-SeedStressCalendarData"
    static let stressCalendarPrefix = "Folio Stress"

    private static let stressEventCalendarNames = [
        "Work", "Personal", "Family", "Gym", "Projects", "Travel", "Holidays", "Classes", "Clients", "Side Hustle"
    ]
    private static let stressReminderListNames = ["Inbox", "Errands", "Work Tasks", "Home"]
    private static let stressEventTitles = [
        "Standup", "Design Review", "Planning", "Lunch", "Coffee Chat", "Workout", "Focus Time", "Retro",
        "Customer Call", "Interview", "Commute", "Dinner", "Yoga", "Piano Lesson", "Code Review", "All Hands"
    ]
    private static let stressReminderTitles = [
        "Pay rent", "Buy milk", "Reply to email", "Book flights", "Pick up parcel", "Clean desk",
        "Call mum", "Update report", "Water plants", "Renew subscription"
    ]

    public func seedStressData(daysAround dayRadius: Int = 90, calendar: Calendar = .current) async throws {
        if !authorizationStatus(for: .event).allowsReading {
            _ = try await requestFullAccess(to: .event)
        }
        if !authorizationStatus(for: .reminder).allowsReading {
            _ = try await requestFullAccess(to: .reminder)
        }
        let today = calendar.startOfDay(for: .now)
        let days = -dayRadius...dayRadius
        var generator = StressRandomGenerator(seed: 42)
        let eventCalendars = try Self.stressEventCalendarNames.enumerated().compactMap { index, name in
            try makeStressCalendar(named: name, for: .event, hue: Double(index) / 10)
        }
        for day in days {
            let date = calendar.date(byAdding: .day, value: day, to: today) ?? today
            try seedStressEvents(on: date, into: eventCalendars, generator: &generator, calendar: calendar)
        }
        try eventStore.commit()
        let reminderLists = try Self.stressReminderListNames.enumerated().compactMap { index, name in
            try makeStressCalendar(named: name, for: .reminder, hue: 0.05 + Double(index) / 4)
        }
        for day in days {
            let date = calendar.date(byAdding: .day, value: day, to: today) ?? today
            try seedStressReminders(on: date, into: reminderLists, generator: &generator, calendar: calendar)
        }
        try eventStore.commit()
    }

    private func makeStressCalendar(named name: String, for kind: CalendarItemKind, hue: Double) throws -> EKCalendar? {
        let title = "\(Self.stressCalendarPrefix) \(name)"
        for existing in eventStore.calendars(for: kind.entityType) where existing.title == title {
            try eventStore.removeCalendar(existing, commit: false)
        }
        let defaultCalendar = kind == .event
            ? eventStore.defaultCalendarForNewEvents
            : eventStore.defaultCalendarForNewReminders()
        guard let source = defaultCalendar?.source
            ?? eventStore.sources.first(where: { $0.sourceType == .local }) else { return nil }
        let stressCalendar = EKCalendar(for: kind.entityType, eventStore: eventStore)
        stressCalendar.title = title
        stressCalendar.source = source
        stressCalendar.cgColor = Self.stressColor(hue: hue)
        try eventStore.saveCalendar(stressCalendar, commit: false)
        return stressCalendar
    }

    private func seedStressEvents(
        on day: Date, into calendars: [EKCalendar], generator: inout StressRandomGenerator, calendar: Calendar
    ) throws {
        guard !calendars.isEmpty else { return }
        for _ in 0..<Int.random(in: 8...14, using: &generator) {
            let hour = Int.random(in: 7...21, using: &generator)
            let minute = [0, 15, 30, 45].randomElement(using: &generator) ?? 0
            let start = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day) ?? day
            let minutes = [15, 30, 45, 60, 90, 120].randomElement(using: &generator) ?? 60
            try saveStressEvent(
                titled: Self.stressEventTitles.randomElement(using: &generator) ?? "Event",
                in: calendars.randomElement(using: &generator) ?? calendars[0],
                start: start, end: start.addingTimeInterval(TimeInterval(minutes * 60)), isAllDay: false
            )
        }
        for _ in 0..<Int.random(in: 0...3, using: &generator) {
            let length = Int.random(in: 1...3, using: &generator)
            try saveStressEvent(
                titled: "All-day \(Self.stressEventTitles.randomElement(using: &generator) ?? "Event")",
                in: calendars.randomElement(using: &generator) ?? calendars[0],
                start: day, end: calendar.date(byAdding: .day, value: length, to: day) ?? day, isAllDay: true
            )
        }
    }

    private func saveStressEvent(
        titled title: String, in calendar: EKCalendar, start: Date, end: Date, isAllDay: Bool
    ) throws {
        let event = EKEvent(eventStore: eventStore)
        event.calendar = calendar
        event.title = title
        event.startDate = start
        event.endDate = end
        event.isAllDay = isAllDay
        try eventStore.save(event, span: .thisEvent, commit: false)
    }

    private func seedStressReminders(
        on day: Date, into lists: [EKCalendar], generator: inout StressRandomGenerator, calendar: Calendar
    ) throws {
        guard !lists.isEmpty else { return }
        for _ in 0..<Int.random(in: 2...6, using: &generator) {
            let reminder = EKReminder(eventStore: eventStore)
            reminder.calendar = lists.randomElement(using: &generator) ?? lists[0]
            reminder.title = Self.stressReminderTitles.randomElement(using: &generator) ?? "Reminder"
            var components = calendar.dateComponents([.year, .month, .day], from: day)
            if Bool.random(using: &generator) {
                components.hour = Int.random(in: 8...20, using: &generator)
                components.minute = 0
            }
            reminder.dueDateComponents = components
            reminder.isCompleted = day < calendar.startOfDay(for: .now) && Bool.random(using: &generator)
            try eventStore.save(reminder, commit: false)
        }
    }

    private static func stressColor(hue: Double) -> CGColor {
        CGColor(
            srgbRed: 0.5 + 0.4 * cos(2 * .pi * hue),
            green: 0.5 + 0.4 * cos(2 * .pi * (hue - 1.0 / 3)),
            blue: 0.5 + 0.4 * cos(2 * .pi * (hue - 2.0 / 3)),
            alpha: 1
        )
    }
}

private struct StressRandomGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var mixed = state
        mixed = (mixed ^ (mixed >> 30)) &* 0xBF58_476D_1CE4_E5B9
        mixed = (mixed ^ (mixed >> 27)) &* 0x94D0_49BB_1331_11EB
        return mixed ^ (mixed >> 31)
    }
}
#endif
