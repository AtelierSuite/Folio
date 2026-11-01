import Foundation

public struct NotificationSnoozeDurations: Sendable, Hashable {
    public static let standard = NotificationSnoozeDurations(shortMinutes: 5, longMinutes: 15)
    public static let choices: [Int] = [1, 5, 10, 15, 20, 30, 45, 60, 90, 120, 180, 240, 360, 480, 720, 1440]

    public var shortMinutes: Int
    public var longMinutes: Int

    public init(shortMinutes: Int, longMinutes: Int) {
        self.shortMinutes = Self.clamped(shortMinutes)
        self.longMinutes = Self.clamped(longMinutes)
    }

    public static func title(forMinutes minutes: Int) -> String {
        Duration.seconds(minutes * 60).formatted(.units(allowed: [.hours, .minutes], width: .wide))
    }

    private static func clamped(_ minutes: Int) -> Int {
        min(max(minutes, 1), 24 * 60)
    }
}
