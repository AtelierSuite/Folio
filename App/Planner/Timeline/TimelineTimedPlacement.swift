import Foundation

public struct TimelineTimedPlacement: Sendable, Hashable, Identifiable {
    public let entry: TimelineEntry
    public let dayIndex: Int
    public let startHour: Double
    public let endHour: Double
    public let column: Int
    public let columnSpan: Int
    public let columnCount: Int
    public let continuesFromPreviousDay: Bool
    public let continuesToNextDay: Bool

    public var id: String {
        "\(entry.id)@\(dayIndex)"
    }

    public var leadingFraction: Double {
        Double(column) / Double(columnCount)
    }

    public var widthFraction: Double {
        Double(columnSpan) / Double(columnCount)
    }
}
