import Foundation

public enum TravelTransport: String, Sendable, CaseIterable, Identifiable {
    case driving
    case walking
    case transit

    public var id: String {
        rawValue
    }
}
