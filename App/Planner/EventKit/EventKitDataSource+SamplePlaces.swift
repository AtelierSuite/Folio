#if DEBUG
import CoreLocation
import EventKit

extension EventKitDataSource {
    /// Places for some sample events, so weather can show rain highlights and a travel day.
    static func applySamplePlace(to event: EKEvent) {
        guard let place = samplePlaces[event.title ?? ""] else { return }
        let location = EKStructuredLocation(title: place.name)
        location.geoLocation = CLLocation(
            latitude: place.coordinate.latitude, longitude: place.coordinate.longitude
        )
        event.structuredLocation = location
    }

    private static let samplePlaces: [String: WeatherPlace] = [
        "Lunch with Aiko": WeatherPlace(
            name: "Shibuya", coordinate: PlannerCoordinate(latitude: 35.658, longitude: 139.701)
        ),
        "Dentist": WeatherPlace(
            name: "Shinjuku", coordinate: PlannerCoordinate(latitude: 35.690, longitude: 139.700)
        ),
        "Team Offsite": WeatherPlace(
            name: "Osaka", coordinate: PlannerCoordinate(latitude: 34.693, longitude: 135.502)
        ),
        "Concert": WeatherPlace(
            name: "Yokohama Arena", coordinate: PlannerCoordinate(latitude: 35.512, longitude: 139.620)
        )
    ]
}
#endif
