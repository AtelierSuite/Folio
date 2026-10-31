import Foundation
import Observation
import os

let leaveLog = Logger(subsystem: "com.tsubuzaki.Folio", category: "LeaveAlerts")

@MainActor
@Observable
public final class LeaveAlertCenter {
    public let isSupported: Bool
    public internal(set) var isEnabled: Bool
    public internal(set) var transport: TravelTransport
    public internal(set) var authorization: ArrivalAuthorization = .notDetermined
    public internal(set) var scheduledAlerts: [LeaveAlert] = []

    @ObservationIgnored let locator: (any LeaveLocating)?
    @ObservationIgnored let source: any CalendarDataSource
    @ObservationIgnored let settings: LeaveAlertSettings
    @ObservationIgnored let notificationSettings: NotificationSettings
    @ObservationIgnored let visibilityStorage: CalendarVisibilityStorage
    @ObservationIgnored let preferences: any ArrivalAlertEventPreferences
    @ObservationIgnored let resolver: EventCoordinateResolver
    @ObservationIgnored let estimator: any TravelTimeEstimating
    @ObservationIgnored let planner: LeaveAlertPlanner
    @ObservationIgnored let scheduler: any LeaveAlertScheduling
    @ObservationIgnored let ledger: LeaveAlertLedger
    @ObservationIgnored let clock: @Sendable () -> Date
    @ObservationIgnored private var replanLoop: Task<Void, Never>?
    @ObservationIgnored private var needsReplan = false

    public init(
        capabilities: PlatformCapabilities,
        makeLocator: @MainActor () -> any LeaveLocating = { CoreLocationLeaveLocator() },
        source: any CalendarDataSource = EventKitDataSource.shared,
        settings: LeaveAlertSettings = LeaveAlertSettings(),
        notificationSettings: NotificationSettings = NotificationSettings(),
        visibilityStorage: CalendarVisibilityStorage = CalendarVisibilityStorage(),
        preferences: any ArrivalAlertEventPreferences = ArrivalAlertPreferences.leaveAlerts(),
        resolver: EventCoordinateResolver = EventCoordinateResolver(),
        estimator: any TravelTimeEstimating = MapKitTravelTimeEstimator(),
        planner: LeaveAlertPlanner = LeaveAlertPlanner(),
        scheduler: any LeaveAlertScheduling = UserNotificationLeaveAlertScheduler(),
        ledger: LeaveAlertLedger = LeaveAlertLedger(),
        clock: @escaping @Sendable () -> Date = { .now }
    ) {
        isSupported = capabilities.supports(.leaveAlerts)
        locator = isSupported ? makeLocator() : nil
        self.source = source
        self.settings = settings
        self.notificationSettings = notificationSettings
        self.visibilityStorage = visibilityStorage
        self.preferences = preferences
        self.resolver = resolver
        self.estimator = estimator
        self.planner = planner
        self.scheduler = scheduler
        self.ledger = ledger
        self.clock = clock
        isEnabled = isSupported && settings.isEnabled
        transport = settings.transport
        authorization = locator?.authorization ?? .notDetermined
        locator?.onAuthorizationChange = { [weak self] in
            guard let self else { return }
            authorization = locator?.authorization ?? .notDetermined
            Task { await self.replan() }
        }
    }

    var isActive: Bool {
        isEnabled && notificationSettings.isEnabled && authorization.allowsMonitoring
    }

    public func replan() async {
        needsReplan = true
        if let replanLoop {
            await replanLoop.value
            return
        }
        let loop = Task {
            while needsReplan {
                needsReplan = false
                await performReplan()
            }
            replanLoop = nil
        }
        replanLoop = loop
        await loop.value
    }

    private func performReplan() async {
        guard let locator else { return }
        authorization = locator.authorization
        let now = clock()
        var alerts: [LeaveAlert] = []
        if isActive {
            guard let origin = await locator.currentCoordinate() else {
                leaveLog.info("Kept leave alerts as they were, since the current location is unknown")
                return
            }
            alerts = await plannedAlerts(from: origin, now: now)
        }
        let desired = Set(alerts.map(\.id))
        let pending = await scheduler.pendingIdentifiers()
        await scheduler.removePending(withIdentifiers: pending.filter { !desired.contains($0) })
        for alert in alerts where !pending.contains(alert.id) {
            await scheduler.schedule(alert, now: now)
        }
        ledger.record(alerts, now: now)
        scheduledAlerts = alerts
        leaveLog.info("Scheduled \(alerts.count) leave alerts")
    }

    private func plannedAlerts(from origin: PlannerCoordinate, now: Date) async -> [LeaveAlert] {
        let hiddenCalendars = visibilityStorage.hiddenCalendarIdentifiers
        var alerts: [LeaveAlert] = []
        for event in await source.events(in: planner.interval(after: now))
        where !hiddenCalendars.contains(event.calendarIdentifier) && preferences.isEnabled(for: event.reference) {
            guard planner.isEligible(event, now: now), !ledger.hasFired(for: event, now: now),
                  let destination = await resolver.coordinate(for: event),
                  planner.needsTravel(from: origin, to: destination),
                  let travelTime = try? await estimator.travelTime(
                    from: origin, to: destination, by: transport, arrivingAt: event.startDate
                  ),
                  let alert = planner.alert(
                    for: event, to: destination, travelTime: travelTime, transport: transport, now: now
                  ) else { continue }
            alerts.append(alert)
        }
        return alerts
    }
}
