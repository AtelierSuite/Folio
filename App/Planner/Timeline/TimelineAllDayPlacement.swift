import Foundation

public struct TimelineAllDayPlacement: Sendable, Hashable, Identifiable {
    public let entry: TimelineEntry
    public let firstDayIndex: Int
    public let lastDayIndex: Int
    public let lane: Int
    public let continuesFromBefore: Bool
    public let continuesAfter: Bool

    public var id: String {
        entry.id
    }

    public var dayCount: Int {
        lastDayIndex - firstDayIndex + 1
    }
}
