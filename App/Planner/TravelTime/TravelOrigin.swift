import Foundation

/// Where the trip to the first event with a place each day starts.
public enum TravelOrigin: String, CaseIterable, Identifiable, Sendable {
    case currentLocation
    case specificLocation

    public var id: String { rawValue }
}
