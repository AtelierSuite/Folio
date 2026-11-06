import Foundation

public struct WidgetLeaveBy: Sendable, Hashable {
    public enum Urgency: Sendable, Hashable {
        case relaxed
        case soon
        case overdue
    }

    public static let soonThreshold: TimeInterval = 15 * 60
    public static let rainThreshold = 0.4
    private static let everyMinuteWindow: TimeInterval = 30 * 60
    private static let everyFewMinutes: TimeInterval = 5 * 60

    public let event: CalendarEvent
    public let leaveDate: Date
    public let travelTime: TimeInterval
    public let transport: TravelTransport
    public let needsUmbrella: Bool

    public func timeUntilLeaving(at date: Date) -> TimeInterval {
        leaveDate.timeIntervalSince(date)
    }

    public func urgency(at date: Date) -> Urgency {
        let remaining = timeUntilLeaving(at: date)
        if remaining <= 0 { return .overdue }
        return remaining <= Self.soonThreshold ? .soon : .relaxed
    }

    /// Every minute close to leaving, every few minutes before that, then when the event starts.
    public func timelineDates(after now: Date) -> [Date] {
        let closeStart = max(now, leaveDate.addingTimeInterval(-Self.everyMinuteWindow))
        let early = stride(from: now, to: closeStart, by: Self.everyFewMinutes).map { $0 }
        let close = stride(from: closeStart, through: leaveDate, by: 60).map { $0 }
        return early + close + [event.startDate]
    }
}

extension WidgetSnapshot {
    public func leaveBy(at date: Date) -> WidgetLeaveBy? {
        guard let leaveByPlan,
              let event = events.first(where: {
                  $0.reference.storageKey == leaveByPlan.eventKey && $0.startDate > date
              }) else { return nil }
        return WidgetLeaveBy(
            event: event,
            leaveDate: leaveByPlan.leaveDate(for: event),
            travelTime: leaveByPlan.travelTime,
            transport: leaveByPlan.travelTransport,
            needsUmbrella: (leaveByRainChance ?? 0) >= WidgetLeaveBy.rainThreshold
        )
    }
}
