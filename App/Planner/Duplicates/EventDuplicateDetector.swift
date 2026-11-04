import Foundation

public struct EventDuplicateDetector: Sendable {
    public var calendar: Calendar

    public init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    /// Groups are returned in the order their earliest event appears in `events`.
    public func groups(in events: [CalendarEvent]) -> [EventDuplicateGroup] {
        let positioned = events.enumerated().map { PositionedEvent(position: $0.offset, event: $0.element) }
        return Dictionary(grouping: positioned, by: startKey(for:))
            .values
            .flatMap { clusters($0) }
            .sorted { $0[0].position < $1[0].position }
            .map { group($0) }
    }

    private func startKey(for item: PositionedEvent) -> StartKey {
        let event = item.event
        let start = event.isAllDay ? calendar.startOfDay(for: event.startDate) : event.startDate
        return StartKey(isAllDay: event.isAllDay, second: Int(start.timeIntervalSinceReferenceDate.rounded(.down)))
    }

    private func clusters(_ items: [PositionedEvent]) -> [[PositionedEvent]] {
        guard items.count > 1 else { return [items] }
        var clusters: [[DuplicateSignature]] = []
        for item in items {
            let signature = DuplicateSignature(item, calendar: calendar)
            let matching = clusters.indices.filter { index in
                clusters[index].contains { $0.isDuplicate(of: signature) }
            }
            let merged = matching.flatMap { clusters[$0] } + [signature]
            for index in matching.reversed() {
                clusters.remove(at: index)
            }
            clusters.append(merged.sorted { $0.item.position < $1.item.position })
        }
        return clusters.map { $0.map(\.item) }
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

    private struct StartKey: Hashable {
        let isAllDay: Bool
        let second: Int
    }
}

struct PositionedEvent {
    let position: Int
    let event: CalendarEvent
}
