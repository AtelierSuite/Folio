#if DEBUG
import CoreLocation
import EventKit

extension EventKitDataSource {
    public static let arrivalTestLaunchArgument = "-SeedArrivalTestEvent"
    public static let arrivalTestCoordinate = PlannerCoordinate(latitude: 37.3349, longitude: -122.0090)
    static let arrivalTestTitle = "Folio Arrival Test"

    @discardableResult
    public func seedArrivalTestEvent(startingIn startDelay: TimeInterval = 1800) throws -> CalendarItemReference? {
        guard authorizationStatus(for: .event).allowsReading,
              let calendar = eventStore.defaultCalendarForNewEvents else { return nil }
        let now = Date.now
        let window = eventStore.predicateForEvents(
            withStart: now.addingTimeInterval(-86_400), end: now.addingTimeInterval(86_400), calendars: nil
        )
        for existing in eventStore.events(matching: window) where existing.title == Self.arrivalTestTitle {
            try eventStore.remove(existing, span: .thisEvent, commit: false)
        }
        let event = EKEvent(eventStore: eventStore)
        event.calendar = calendar
        event.title = Self.arrivalTestTitle
        let location = EKStructuredLocation(title: "Apple Park")
        location.geoLocation = CLLocation(
            latitude: Self.arrivalTestCoordinate.latitude, longitude: Self.arrivalTestCoordinate.longitude
        )
        event.structuredLocation = location
        event.startDate = now.addingTimeInterval(startDelay)
        event.endDate = event.startDate.addingTimeInterval(3600)
        try eventStore.save(event, span: .thisEvent, commit: true)
        return CalendarItemReference(event)
    }
}
#endif
