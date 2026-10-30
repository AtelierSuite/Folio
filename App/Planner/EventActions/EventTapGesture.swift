import Foundation

public enum EventTapGesture: Sendable {
    case tap
    case doubleTap
}

public enum EventTapOutcome: Sendable, Equatable {
    case showDetails
    case showMenu
    case select
}

extension EventTapBehavior {
    /// With a pointer a click selects (or opens the menu) and a double-click opens details,
    /// like Calendar on the Mac. With touch a tap does what the setting says.
    public func outcome(of gesture: EventTapGesture, usesPointerSelection: Bool) -> EventTapOutcome {
        switch (self, gesture) {
        case (_, .doubleTap): .showDetails
        case (.showsQuickActions, .tap): .showMenu
        case (.opensDetails, .tap): usesPointerSelection ? .select : .showDetails
        }
    }
}

extension PlatformCapabilities {
    public var usesPointerSelection: Bool {
        platform == .mac
    }
}
