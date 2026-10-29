import Foundation

public struct TimelineTimePosition: Sendable, Hashable {
    public let dayIndex: Int
    public let hour: Double

    public init(dayIndex: Int, hour: Double) {
        self.dayIndex = dayIndex
        self.hour = hour
    }
}
