import Observation
import Planner
import WidgetKit

@MainActor
@Observable
final class WatchCalendarModel {
    private(set) var authorization: CalendarAuthorizationStatus
    /// Goes up whenever the calendars change, so views reload their events.
    private(set) var revision = 0

    @ObservationIgnored private let source: any CalendarDataSource
    @ObservationIgnored private let loader: WidgetSnapshotLoader
    @ObservationIgnored private var changeObservation: Task<Void, Never>?

    init(source: any CalendarDataSource = EventKitDataSource.shared) {
        self.source = source
        loader = WidgetSnapshotLoader(source: source)
        authorization = source.authorizationStatus(for: .event)
        #if DEBUG
        if WatchSampleEvents.isEnabled {
            authorization = .fullAccess
        }
        #endif
        observeChanges()
    }

    var canReadEvents: Bool {
        authorization.allowsReading
    }

    func requestAccess() async {
        _ = try? await source.requestFullAccess(to: .event)
        refreshAuthorization()
    }

    func refreshAuthorization() {
        let status = source.authorizationStatus(for: .event)
        guard status != authorization, !isShowingSamples else { return }
        authorization = status
        calendarsDidChange()
    }

    func events(for request: WidgetSnapshotRequest, at now: Date) async -> [CalendarEvent] {
        #if DEBUG
        if WatchSampleEvents.isEnabled, let interval = request.eventInterval {
            return WatchSampleEvents.events(in: interval)
        }
        #endif
        return await loader.load(request, at: now).events
    }

    private var isShowingSamples: Bool {
        #if DEBUG
        WatchSampleEvents.isEnabled
        #else
        false
        #endif
    }

    private func observeChanges() {
        let changes = source.changes()
        changeObservation = Task { [weak self] in
            for await _ in changes {
                self?.calendarsDidChange()
            }
        }
    }

    private func calendarsDidChange() {
        revision += 1
        WidgetCenter.shared.reloadAllTimelines()
    }
}
