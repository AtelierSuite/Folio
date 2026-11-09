import Foundation

/// Whether Leave By can work out routes, so the widget knows which step of setup to ask for.
public enum LeaveByStatus: String, Sendable, Hashable, Codable {
    case off
    case needsAlwaysLocation
    case tracking
}
