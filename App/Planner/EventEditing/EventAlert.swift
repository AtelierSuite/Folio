import Foundation

public struct EventAlert: Sendable, Hashable, Identifiable {
    public let offset: TimeInterval

    public init(offset: TimeInterval) {
        self.offset = offset
    }

    public var id: TimeInterval { offset }

    public static func minutesBefore(_ minutes: Double) -> EventAlert {
        EventAlert(offset: -minutes * 60)
    }

    public static let timedPresets: [EventAlert] = [
        EventAlert(offset: 0),
        .minutesBefore(5),
        .minutesBefore(10),
        .minutesBefore(15),
        .minutesBefore(30),
        .minutesBefore(60),
        .minutesBefore(120),
        .minutesBefore(24 * 60),
        .minutesBefore(2 * 24 * 60),
        .minutesBefore(7 * 24 * 60)
    ]

    /// All-day alerts are offsets from midnight, so these fire at 9:00 on the day.
    public static let allDayPresets: [EventAlert] = [
        EventAlert(offset: 9 * 3600),
        EventAlert(offset: -15 * 3600),
        EventAlert(offset: -39 * 3600),
        EventAlert(offset: -159 * 3600)
    ]

    public static func presets(isAllDay: Bool) -> [EventAlert] {
        isAllDay ? allDayPresets : timedPresets
    }

    public static func defaultAlert(isAllDay: Bool) -> EventAlert {
        isAllDay ? allDayPresets[1] : .minutesBefore(15)
    }
}
