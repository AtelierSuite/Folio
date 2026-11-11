import Foundation

/// What the Flex Time sheet offers for one day. Events carry their calendar times, not delayed ones.
public struct FlexTimeProposal: Sendable, Hashable, Identifiable {
    public let day: Date
    public let events: [CalendarEvent]
    public let wake: FlexTimeWake?
    public let suggestedStart: Date
    public let latestStart: Date
    public let activeDelay: TimeInterval

    public init(
        day: Date,
        events: [CalendarEvent],
        wake: FlexTimeWake?,
        suggestedStart: Date,
        latestStart: Date,
        activeDelay: TimeInterval = 0
    ) {
        self.day = day
        self.events = events
        self.wake = wake
        self.suggestedStart = suggestedStart
        self.latestStart = latestStart
        self.activeDelay = activeDelay
    }

    public var id: Date { day }

    public var firstEvent: CalendarEvent? {
        events.first
    }

    public var isActive: Bool {
        activeDelay > 0
    }

    public var startRange: ClosedRange<Date> {
        let earliest = firstEvent?.startDate ?? day
        return earliest...max(earliest, latestStart)
    }

    public func delay(startingFirstEventAt start: Date) -> TimeInterval {
        guard let firstEvent else { return 0 }
        let minutes = (start.timeIntervalSince(firstEvent.startDate) / 60).rounded()
        return max(0, minutes * 60)
    }
}
