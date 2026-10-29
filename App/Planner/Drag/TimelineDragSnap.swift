import Foundation

public enum TimelineDragSnap: Int, Sendable, Hashable, CaseIterable {
    case fiveMinutes = 5
    case fifteenMinutes = 15

    public static let `default` = TimelineDragSnap.fifteenMinutes

    public var minutes: Int {
        rawValue
    }

    public var hours: Double {
        Double(rawValue) / 60
    }

    public func snapped(_ hour: Double) -> Double {
        (hour / hours).rounded() * hours
    }
}
