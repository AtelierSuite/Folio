#if os(macOS)
import Foundation
import Observation
import Planner

/// Keeps the next event for the menu bar item and today's date, refreshing on calendar changes and every minute.
@MainActor
@Observable
final class MenuBarAgenda {
    private(set) var upNext: MenuBarUpNext?
    private(set) var today: Date
    @ObservationIgnored private var events: [CalendarEvent] = []
    @ObservationIgnored private var tasks: [Task<Void, Never>] = []
    @ObservationIgnored private let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
        today = calendar.startOfDay(for: .now)
    }

    static func started(with store: CalendarStore) -> MenuBarAgenda {
        let agenda = MenuBarAgenda()
        agenda.start(with: store)
        return agenda
    }

    func start(with store: CalendarStore) {
        guard tasks.isEmpty else { return }
        store.startObservingChanges()
        let revisions = Observations { store.contentRevision }
        tasks = [
            Task { [weak self] in
                for await _ in revisions {
                    await self?.reload(from: store)
                }
            },
            Task { [weak self] in
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(Self.secondsUntilNextMinute()))
                    await self?.tick(store: store)
                }
            }
        ]
    }

    private func tick(store: CalendarStore) async {
        let startOfToday = calendar.startOfDay(for: .now)
        guard startOfToday == today else {
            today = startOfToday
            await reload(from: store)
            return
        }
        refreshUpNext()
    }

    private func reload(from store: CalendarStore) async {
        let start = calendar.startOfDay(for: .now)
        let end = calendar.date(byAdding: .day, value: 2, to: start) ?? start.addingTimeInterval(2 * 86_400)
        events = await store.events(in: DateInterval(start: start, end: end))
        refreshUpNext()
    }

    private func refreshUpNext() {
        let next = MenuBarUpNext(events: events, at: .now)
        if next != upNext {
            upNext = next
        }
    }

    private static func secondsUntilNextMinute() -> Double {
        let seconds = Date.now.timeIntervalSinceReferenceDate
        return 60 - seconds.truncatingRemainder(dividingBy: 60) + 0.5
    }
}
#endif
