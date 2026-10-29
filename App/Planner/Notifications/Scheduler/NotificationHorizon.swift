import Foundation

public struct NotificationHorizon: Sendable {
    public var lookBehind: TimeInterval
    public var lookAhead: TimeInterval

    public init(lookBehind: TimeInterval = 86_400, lookAhead: TimeInterval = 35 * 86_400) {
        self.lookBehind = lookBehind
        self.lookAhead = lookAhead
    }

    public func eventInterval(from now: Date) -> DateInterval {
        DateInterval(start: now.addingTimeInterval(-lookBehind), end: now.addingTimeInterval(lookAhead))
    }
}
