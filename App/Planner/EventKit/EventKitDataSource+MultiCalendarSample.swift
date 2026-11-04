#if DEBUG
import EventKit

extension EventKitDataSource {
    public static let multiCalendarDataLaunchArgument = "-SeedMultiCalendarData"

    /// Overlapping events across differently colored calendars, placed around the current hour.
    public func seedMultiCalendarData(calendar: Calendar = .current) async throws {
        if !authorizationStatus(for: .event).allowsReading {
            _ = try await requestFullAccess(to: .event)
        }
        let hourStart = calendar.dateInterval(of: .hour, for: .now)?.start ?? .now
        for sample in MultiCalendarSample.all {
            guard let eventCalendar = try makeMultiCalendar(sample) else { continue }
            for event in sample.events {
                try save(event, in: eventCalendar, from: hourStart, calendar: calendar)
            }
        }
        try eventStore.commit()
    }

    private func makeMultiCalendar(_ sample: MultiCalendarSample) throws -> EKCalendar? {
        for existing in eventStore.calendars(for: .event) where existing.title == sample.title {
            try eventStore.removeCalendar(existing, commit: false)
        }
        guard let source = eventStore.defaultCalendarForNewEvents?.source
            ?? eventStore.sources.first(where: { $0.sourceType == .local }) else { return nil }
        let eventCalendar = EKCalendar(for: .event, eventStore: eventStore)
        eventCalendar.title = sample.title
        eventCalendar.source = source
        eventCalendar.cgColor = sample.color
        try eventStore.saveCalendar(eventCalendar, commit: false)
        return eventCalendar
    }

    private func save(
        _ sample: MultiCalendarSample.Event,
        in eventCalendar: EKCalendar,
        from hourStart: Date,
        calendar: Calendar
    ) throws {
        let event = EKEvent(eventStore: eventStore)
        event.calendar = eventCalendar
        event.title = sample.title
        event.isAllDay = sample.isAllDay
        event.startDate = sample.isAllDay
            ? calendar.startOfDay(for: hourStart)
            : hourStart.addingTimeInterval(sample.startHours * 3_600)
        event.endDate = event.startDate.addingTimeInterval(sample.hours * 3_600)
        try eventStore.save(event, span: .thisEvent, commit: false)
    }
}

private struct MultiCalendarSample {
    struct Event {
        let title: String
        let startHours: Double
        let hours: Double
        var isAllDay = false
    }

    let title: String
    let color: CGColor
    let events: [Event]

    static let all = [
        MultiCalendarSample(
            title: "Folio Work",
            color: CGColor(srgbRed: 0.2, green: 0.47, blue: 0.96, alpha: 1),
            events: [
                Event(title: "Sprint Planning", startHours: 0, hours: 1.5),
                Event(title: "Budget Review", startHours: 3, hours: 2)
            ]
        ),
        MultiCalendarSample(
            title: "Folio Personal",
            color: CGColor(srgbRed: 0.2, green: 0.7, blue: 0.35, alpha: 1),
            events: [
                Event(title: "Gym", startHours: 1, hours: 1),
                Event(title: "Dentist", startHours: 6, hours: 1)
            ]
        ),
        MultiCalendarSample(
            title: "Folio Family",
            color: CGColor(srgbRed: 0.96, green: 0.55, blue: 0.2, alpha: 1),
            events: [
                Event(title: "School Pickup", startHours: 0.5, hours: 1),
                Event(title: "Family Dinner", startHours: 7, hours: 1)
            ]
        ),
        MultiCalendarSample(
            title: "Folio Projects",
            color: CGColor(srgbRed: 0.69, green: 0.32, blue: 0.87, alpha: 1),
            events: [
                Event(title: "Release Prep", startHours: 2, hours: 3),
                Event(title: "Pair Session", startHours: 1, hours: 1)
            ]
        ),
        MultiCalendarSample(
            title: "Folio Holidays",
            color: CGColor(srgbRed: 0.9, green: 0.22, blue: 0.27, alpha: 1),
            events: [Event(title: "Founders Day", startHours: 0, hours: 24, isAllDay: true)]
        )
    ]
}
#endif
