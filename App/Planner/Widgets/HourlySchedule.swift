import Foundation

/// A window of upcoming hours with events packed into horizontal lanes, positioned as
/// fractions of the window so a view only has to scale them to its width.
public struct HourlySchedule: Sendable, Equatable {
    public struct Strip: Identifiable, Sendable, Equatable {
        public let event: CalendarEvent
        public let lane: Int
        public let startFraction: Double
        public let endFraction: Double

        public var id: String { event.id }
    }

    public static let defaultHourCount = 6
    public static let defaultLaneLimit = 4
    private static let shortestStripHours = 0.25

    public let hours: [Date]
    public let nowFraction: Double
    public let strips: [Strip]
    public let hiddenCount: Int

    public init(
        events: [CalendarEvent],
        at now: Date,
        calendar: Calendar,
        hourCount: Int = Self.defaultHourCount,
        laneLimit: Int = Self.defaultLaneLimit
    ) {
        let start = calendar.dateInterval(of: .hour, for: now)?.start ?? now
        let duration = Double(hourCount) * 3_600
        let window = DateInterval(start: start, duration: duration)
        hours = (0..<hourCount).map { start.addingTimeInterval(Double($0) * 3_600) }
        nowFraction = now.timeIntervalSince(start) / duration

        let shown = events.filter { $0.overlaps(window) }
        let allDay = shown.filter(\.isAllDay)
        var strips = allDay.first.map { [Strip(event: $0, lane: 0, startFraction: 0, endFraction: 1)] } ?? []
        let firstTimedLane = strips.count
        var laneEnds = Array(repeating: 0.0, count: max(laneLimit - firstTimedLane, 0))
        var hiddenCount = max(allDay.count - 1, 0)

        let shortestFraction = Self.shortestStripHours / Double(hourCount)
        for event in shown where !event.isAllDay {
            let extent = Self.extent(of: event, in: window, shortestFraction: shortestFraction)
            if let lane = laneEnds.firstIndex(where: { $0 <= extent.lowerBound }) {
                laneEnds[lane] = extent.upperBound
                strips.append(Strip(
                    event: event,
                    lane: lane + firstTimedLane,
                    startFraction: extent.lowerBound,
                    endFraction: extent.upperBound
                ))
            } else {
                hiddenCount += 1
            }
        }
        self.strips = strips
        self.hiddenCount = hiddenCount
    }

    private static func extent(
        of event: CalendarEvent,
        in window: DateInterval,
        shortestFraction: Double
    ) -> ClosedRange<Double> {
        let startFraction = event.startDate.timeIntervalSince(window.start) / window.duration
        let endFraction = event.endDate.timeIntervalSince(window.start) / window.duration
        let lowerBound = min(max(startFraction, 0), 1 - shortestFraction)
        let upperBound = min(max(endFraction, lowerBound + shortestFraction), 1)
        return lowerBound...upperBound
    }
}
