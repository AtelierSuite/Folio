import Foundation

struct RingEventLane {
    var event: LabEvent
    var lane: Int
}

enum RingGeometry {
    /// Midnight sits at the bottom so the daylight hours arc over the top.
    nonisolated static func angleDegrees(forFraction fraction: Double) -> Double {
        fraction * 360 + 90
    }

    static func fraction(of date: Date, from startOfDay: Date) -> Double {
        date.timeIntervalSince(startOfDay) / 86_400
    }

    static func lanes(for events: [LabEvent]) -> [RingEventLane] {
        var laneEnds: [Date] = []
        return events.filter { !$0.isAllDay }.sorted { $0.start < $1.start }.map { event in
            if let lane = laneEnds.firstIndex(where: { $0 <= event.start }) {
                laneEnds[lane] = event.end
                return RingEventLane(event: event, lane: lane)
            }
            laneEnds.append(event.end)
            return RingEventLane(event: event, lane: laneEnds.count - 1)
        }
    }
}
