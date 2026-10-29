import Foundation
import Testing
@testable import Planner

struct WeatherLocationKeyTests {
    @Test func roundsToATenthOfADegree() {
        let key = WeatherLocationKey(PlannerCoordinate(latitude: 35.6812, longitude: 139.7671))
        #expect(key.coordinate == PlannerCoordinate(latitude: 35.7, longitude: 139.8))
        #expect(key.pathComponent == "35.7_139.8")
    }

    @Test func nearbyPlacesShareAKey() {
        #expect(WeatherLocationKey(WeatherFixtures.tokyo) == WeatherLocationKey(
            PlannerCoordinate(latitude: 35.71, longitude: 139.79)
        ))
        #expect(WeatherLocationKey(WeatherFixtures.tokyo) != WeatherLocationKey(WeatherFixtures.osaka))
    }

    @Test func negativeCoordinatesKeepTheirSign() {
        let key = WeatherLocationKey(PlannerCoordinate(latitude: -33.8688, longitude: -151.2093))
        #expect(key.pathComponent == "-33.9_-151.2")
    }

    @Test func longitudeWrapsAroundTheAntimeridian() {
        let east = WeatherLocationKey(PlannerCoordinate(latitude: 0, longitude: 179.98))
        let west = WeatherLocationKey(PlannerCoordinate(latitude: 0, longitude: -179.98))
        let wrapped = WeatherLocationKey(PlannerCoordinate(latitude: 0, longitude: 190))
        #expect(east == west)
        #expect(wrapped.coordinate.longitude == -170)
    }

    @Test func latitudeIsClamped() {
        let key = WeatherLocationKey(PlannerCoordinate(latitude: 95, longitude: 0))
        #expect(key.coordinate.latitude == 90)
    }
}
