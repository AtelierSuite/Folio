import Foundation
import Testing
@testable import Planner

enum DirectionsFixtures {
    static let tokyoStation = PlannerCoordinate(latitude: 35.6812, longitude: 139.7671)
    static let gangnamStation = PlannerCoordinate(latitude: 37.4979, longitude: 127.0276)
    static let tiananmen = PlannerCoordinate(latitude: 39.9087, longitude: 116.3975)

    static func request(
        name: String? = "Tokyo Station",
        coordinate: PlannerCoordinate? = nil,
        transport: TravelTransport? = nil
    ) throws -> DirectionsRequest {
        DirectionsRequest(
            destination: try #require(DirectionsDestination(name: name, coordinate: coordinate)),
            transport: transport
        )
    }

    static func settings() -> DirectionsSettings {
        DirectionsSettings(defaults: UserDefaults(suiteName: "DirectionsFixtures.\(UUID().uuidString)") ?? .standard)
    }

    static func queryItems(_ url: URL?) -> [URLQueryItem] {
        url.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false)?.queryItems } ?? []
    }
}
