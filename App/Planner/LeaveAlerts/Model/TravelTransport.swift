import Foundation

public enum TravelTransport: String, Sendable, Codable, CaseIterable, Identifiable {
    case driving
    case walking
    case transit

    public var id: String {
        rawValue
    }
}
