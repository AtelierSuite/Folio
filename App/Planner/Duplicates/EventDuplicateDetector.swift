import Foundation

public struct EventDuplicateDetector: Sendable {
    public var calendar: Calendar
    public var excludedCalendarIdentifiers: Set<String>

    public init(calendar: Calendar = .current, settings: DuplicateDetectionSettings = .shared) {
        self.calendar = calendar
        excludedCalendarIdentifiers = settings.excludedCalendarIdentifiers
    }

    /// Groups are returned in the order their earliest event appears in `events`.
    public func groups(in events: [CalendarEvent]) -> [EventDuplicateGroup] {
        let positioned = events.enumerated().map { PositionedEvent(position: $0.offset, event: $0.element) }
        let excluded = positioned.filter { excludedCalendarIdentifiers.contains($0.event.calendarIdentifier) }
        let eligible = positioned.filter { !excludedCalendarIdentifiers.contains($0.event.calendarIdentifier) }
        return (clusters(eligible) + excluded.map { [$0] })
            .sorted { firstPosition(of: $0) < firstPosition(of: $1) }
            .map { group($0) }
    }

    private func firstPosition(of cluster: [PositionedEvent]) -> Int {
        cluster.map(\.position).min() ?? 0
    }

    /// An event joins a cluster only if it matches every member, so a run of events
    /// 20 minutes apart can't chain into one group wider than the tolerance.
    private func clusters(_ items: [PositionedEvent]) -> [[PositionedEvent]] {
        let signatures = items
            .map { DuplicateSignature($0, calendar: calendar) }
            .sorted { ($0.start, $0.item.event.id) < ($1.start, $1.item.event.id) }
        var finished: [[DuplicateSignature]] = []
        var open: [[DuplicateSignature]] = []
        for signature in signatures {
            let isOpen = { (cluster: [DuplicateSignature]) in
                signature.start.timeIntervalSince(cluster[0].start) <= DuplicateSignature.timeTolerance
            }
            finished += open.filter { !isOpen($0) }
            open.removeAll { !isOpen($0) }
            if let index = open.firstIndex(where: { $0.allSatisfy { $0.isDuplicate(of: signature) } }) {
                open[index].append(signature)
            } else {
                open.append([signature])
            }
        }
        return (finished + open).map { $0.map(\.item) }
    }

    private func group(_ cluster: [PositionedEvent]) -> EventDuplicateGroup {
        let ranked = cluster.map(\.event).sorted(by: Self.isPreferred)
        return EventDuplicateGroup(primary: ranked[0], duplicates: Array(ranked.dropFirst()))
    }

    private static func isPreferred(_ first: CalendarEvent, over second: CalendarEvent) -> Bool {
        if first.isReadOnly != second.isReadOnly {
            return second.isReadOnly
        }
        let firstDetail = detailScore(of: first)
        let secondDetail = detailScore(of: second)
        return firstDetail == secondDetail ? first.id < second.id : firstDetail > secondDetail
    }

    private static func detailScore(of event: CalendarEvent) -> Int {
        [
            !event.alarms.isEmpty,
            !(event.location ?? "").isEmpty,
            event.url != nil,
            !(event.notes ?? "").isEmpty
        ].filter { $0 }.count
    }
}

struct PositionedEvent {
    let position: Int
    let event: CalendarEvent
}
