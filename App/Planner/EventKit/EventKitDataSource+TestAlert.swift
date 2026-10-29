#if DEBUG
import EventKit

extension EventKitDataSource {
    public static let testAlertLaunchArgument = "-SeedTestAlertEvent"
    static let testAlertTitle = "Folio Test Alert"

    public func seedTestAlertEvent(startingIn startDelay: TimeInterval = 120, alertBefore: TimeInterval = 60) throws {
        guard authorizationStatus(for: .event).allowsReading,
              let calendar = eventStore.defaultCalendarForNewEvents else { return }
        let now = Date.now
        let window = eventStore.predicateForEvents(
            withStart: now.addingTimeInterval(-86_400), end: now.addingTimeInterval(86_400), calendars: nil
        )
        for existing in eventStore.events(matching: window) where existing.title == Self.testAlertTitle {
            try eventStore.remove(existing, span: .thisEvent, commit: false)
        }
        let event = EKEvent(eventStore: eventStore)
        event.calendar = calendar
        event.title = Self.testAlertTitle
        event.location = "Room 4"
        event.startDate = now.addingTimeInterval(startDelay)
        event.endDate = event.startDate.addingTimeInterval(1800)
        event.addAlarm(EKAlarm(relativeOffset: -alertBefore))
        try eventStore.save(event, span: .thisEvent, commit: true)
    }
}
#endif
