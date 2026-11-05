import Foundation

/// The fixed part of an event countdown. `startedAt` anchors the 8-hour Live Activity limit.
public struct EventCountdownAttributes: Sendable, Hashable, Codable {
    public let reference: CalendarItemReference
    public let startedAt: Date

    public init(reference: CalendarItemReference, startedAt: Date) {
        self.reference = reference
        self.startedAt = startedAt
    }

    public func eventURL(for state: ContentState) -> URL {
        CalendarDeepLink.url(forEvent: reference, startingAt: state.startDate)
    }

    public struct ContentState: Sendable, Hashable, Codable {
        public let title: String
        public let location: String?
        public let color: PlannerColor
        public let startDate: Date
        /// Set when the countdown continues with "ends in…" after the event starts.
        public let endDate: Date?
        /// When false, the countdown shows the time to the end from the moment it begins.
        public let countsToStart: Bool

        public init(
            title: String,
            location: String?,
            color: PlannerColor,
            startDate: Date,
            endDate: Date?,
            countsToStart: Bool = true
        ) {
            self.title = title
            self.location = location
            self.color = color
            self.startDate = startDate
            self.endDate = endDate
            self.countsToStart = countsToStart
        }

        public var finishDate: Date {
            endDate ?? startDate
        }
    }
}
