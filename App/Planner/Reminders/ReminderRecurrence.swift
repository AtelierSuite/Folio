import Foundation

public struct ReminderRecurrence: Sendable, Hashable {
    public enum Frequency: String, CaseIterable, Identifiable, Sendable, Hashable {
        case daily
        case weekly
        case monthly
        case yearly

        public var id: Self { self }
    }

    public var frequency: Frequency
    public var interval: Int
    public var endDate: Date?

    public init(frequency: Frequency, interval: Int = 1, endDate: Date? = nil) {
        self.frequency = frequency
        self.interval = max(1, interval)
        self.endDate = endDate
    }
}
