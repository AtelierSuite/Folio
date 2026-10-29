#if DEBUG
import EventKit

extension EventKitDataSource {
    public static let testAlertLaunchArgument = "-SeedTestAlertEvent"
    public static let testAlertTitle = "Folio Test Alert"

    public func seedTestAlertEvent(
        title: String = testAlertTitle,
        location: String? = "Room 4",
        url: URL? = nil,
        startingIn startDelay: TimeInterval = 120,
        alertBefore: TimeInterval = 60
    ) throws {
        guard authorizationStatus(for: .event).allowsReading,
              let calendar = eventStore.defaultCalendarForNewEvents else { return }
        let now = Date.now
        let window = eventStore.predicateForEvents(
            withStart: now.addingTimeInterval(-86_400), end: now.addingTimeInterval(86_400), calendars: nil
        )
        for existing in eventStore.events(matching: window) where existing.title == title {
            try eventStore.remove(existing, span: .thisEvent, commit: false)
        }
        let event = EKEvent(eventStore: eventStore)
        event.calendar = calendar
        event.title = title
        event.location = location
        event.url = url
        event.startDate = now.addingTimeInterval(startDelay)
        event.endDate = event.startDate.addingTimeInterval(1800)
        event.addAlarm(EKAlarm(relativeOffset: -alertBefore))
        try eventStore.save(event, span: .thisEvent, commit: true)
    }
}
#endif
