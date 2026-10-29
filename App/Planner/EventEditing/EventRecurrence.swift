import Foundation

public struct EventRecurrence: Sendable, Hashable {
    public enum Frequency: String, Sendable, Hashable, CaseIterable, Identifiable {
        case daily
        case weekly
        case monthly
        case yearly

        public var id: Self { self }
    }

    public enum End: Sendable, Hashable {
        case never
        case onDate(Date)
        case afterOccurrences(Int)
    }

    public var frequency: Frequency
    public var interval: Int
    public var end: End

    public init(frequency: Frequency, interval: Int = 1, end: End = .never) {
        self.frequency = frequency
        self.interval = max(interval, 1)
        self.end = end
    }
}
