import Foundation

public enum EventTapBehavior: String, Sendable, CaseIterable, Identifiable {
    case opensDetails
    case showsQuickActions

    public var id: String {
        rawValue
    }
}
