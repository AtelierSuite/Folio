import Foundation

enum FreeState: Equatable {
    case free(until: Date)
    case busy(until: Date)
    case dayOver
}

enum FreeGapFinder {
    static let firstHour = 8
    static let lastHour = 22
    static let shortestGapMinutes = 15.0

    static func window(on day: Date, calendar: Calendar) -> DateInterval {
        let start = calendar.date(bySettingHour: firstHour, minute: 0, second: 0, of: day) ?? day
        let end = calendar.date(bySettingHour: lastHour, minute: 0, second: 0, of: day) ?? day
        return DateInterval(start: start, end: end)
    }

    static func busyIntervals(_ events: [LabEvent], in window: DateInterval) -> [DateInterval] {
        let clipped = events
            .filter { !$0.isAllDay }
            .compactMap { $0.occupiedInterval.intersection(with: window) }
            .sorted { $0.start < $1.start }
        return clipped.reduce(into: []) { merged, interval in
            if let last = merged.last, interval.start <= last.end {
                merged[merged.count - 1] = DateInterval(start: last.start, end: max(last.end, interval.end))
            } else {
                merged.append(interval)
            }
        }
    }

    static func gaps(in snapshot: LabSnapshot) -> [DateInterval] {
        let window = window(on: snapshot.now, calendar: snapshot.calendar)
        var cursor = max(window.start, snapshot.now)
        var gaps: [DateInterval] = []
        for busy in busyIntervals(snapshot.eventsToday, in: window) + [DateInterval(start: window.end, duration: 0)] {
            if busy.start > cursor {
                gaps.append(DateInterval(start: cursor, end: busy.start))
            }
            cursor = max(cursor, busy.end)
        }
        return gaps.filter { $0.duration >= shortestGapMinutes * 60 }
    }

    static func state(in snapshot: LabSnapshot) -> FreeState {
        let window = window(on: snapshot.now, calendar: snapshot.calendar)
        guard snapshot.now < window.end else { return .dayOver }
        let busy = busyIntervals(snapshot.eventsToday, in: window)
        if let current = busy.first(where: { $0.contains(snapshot.now) && $0.end != snapshot.now }) {
            return .busy(until: current.end)
        }
        let nextBusy = busy.first { $0.start > snapshot.now }
        return .free(until: nextBusy?.start ?? window.end)
    }
}
