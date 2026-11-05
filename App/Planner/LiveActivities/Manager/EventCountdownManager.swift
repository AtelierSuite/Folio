import Foundation
import Observation

/// Runs at most one countdown per event, keyed by its stable reference.
@MainActor
@Observable
public final class EventCountdownManager {
    public private(set) var running: [RunningCountdown] = []
    @ObservationIgnored let controller: any CountdownActivityControlling
    @ObservationIgnored let source: any CountdownEventSource
    @ObservationIgnored let settings: CountdownSettings
    @ObservationIgnored private var finishTask: Task<Void, Never>?

    public init(
        source: any CountdownEventSource,
        controller: (any CountdownActivityControlling)? = nil,
        settings: CountdownSettings = CountdownSettings()
    ) {
        self.source = source
        self.controller = controller ?? Self.platformController()
        self.settings = settings
        running = self.controller.runningCountdowns
    }

    public var window: CountdownWindow {
        CountdownWindow(phases: settings.phases)
    }

    var reconciler: CountdownReconciler {
        CountdownReconciler(window: window)
    }

    public func availability(for event: CalendarEvent, at now: Date = .now) -> CountdownAvailability {
        window.availability(for: event, at: now)
    }

    public func isCountingDown(_ event: CalendarEvent) -> Bool {
        running.contains { $0.belongs(to: event) }
    }

    public func start(_ event: CalendarEvent, at now: Date = .now) throws {
        refresh()
        guard !isCountingDown(event) else { throw CountdownActivityError.alreadyRunning }
        guard let state = window.availability(for: event, at: now).state else {
            throw CountdownActivityError.outsideWindow
        }
        try controller.start(EventCountdownAttributes(reference: event.reference, startedAt: now), state: state)
        refresh()
    }

    public func stop(_ event: CalendarEvent) async {
        for countdown in controller.runningCountdowns where countdown.belongs(to: event) {
            await controller.end(id: countdown.id)
        }
        refresh()
    }

    public func dismiss(_ countdown: RunningCountdown) async {
        await controller.end(id: countdown.id)
        refresh()
    }

    /// An activity's content can still read as the old state just after an update returns.
    func refresh(applying updatedStates: [String: EventCountdownAttributes.ContentState] = [:]) {
        running = controller.runningCountdowns.map { countdown in
            guard let state = updatedStates[countdown.id] else { return countdown }
            return RunningCountdown(id: countdown.id, attributes: countdown.attributes, state: state)
        }
        scheduleFinish()
    }

    private func scheduleFinish() {
        finishTask?.cancel()
        guard let finishDate = running.map(\.state.finishDate).min() else { return }
        finishTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(max(finishDate.timeIntervalSinceNow, 0) + 1))
            guard !Task.isCancelled else { return }
            await self?.reconcile()
        }
    }

    private static func platformController() -> any CountdownActivityControlling {
        #if os(iOS)
        ActivityKitCountdownController()
        #else
        UnavailableCountdownController()
        #endif
    }
}
