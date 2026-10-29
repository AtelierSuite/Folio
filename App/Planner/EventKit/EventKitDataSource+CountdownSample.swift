#if DEBUG
import EventKit

extension EventKitDataSource {
    public static let countdownSampleLaunchArgument = "-SeedCountdownEvent"
    public static let countdownSampleTitle = "Folio Countdown"

    /// An event inside the countdown window, so UI tests and screenshots have one to start.
    public func seedCountdownSampleEvent(startingIn startDelay: TimeInterval = 30 * 60) throws {
        guard authorizationStatus(for: .event).allowsReading,
              let calendar = eventStore.defaultCalendarForNewEvents else { return }
        let now = Date.now
        let window = eventStore.predicateForEvents(
            withStart: now.addingTimeInterval(-86_400), end: now.addingTimeInterval(86_400), calendars: nil
        )
        for existing in eventStore.events(matching: window) where existing.title == Self.countdownSampleTitle {
            try eventStore.remove(existing, span: .thisEvent, commit: false)
        }
        let event = EKEvent(eventStore: eventStore)
        event.calendar = calendar
        event.title = Self.countdownSampleTitle
        event.location = "Café Folio"
        event.startDate = now.addingTimeInterval(startDelay)
        event.endDate = event.startDate.addingTimeInterval(3600)
        try eventStore.save(event, span: .thisEvent, commit: true)
    }
}
#endif
