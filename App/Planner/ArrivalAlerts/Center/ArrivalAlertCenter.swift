import Foundation
import Observation
import os

let arrivalLog = Logger(subsystem: "com.tsubuzaki.Folio", category: "ArrivalAlerts")

@MainActor
@Observable
public final class ArrivalAlertCenter {
    public static let lookAhead: TimeInterval = 7 * 86_400

    public let isSupported: Bool
    public internal(set) var isEnabled: Bool
    public internal(set) var isLeaveByEnabled: Bool
    public internal(set) var authorization: ArrivalAuthorization = .notDetermined
    public internal(set) var monitoredRegions: [ArrivalRegion] = []

    @ObservationIgnored let regionMonitor: (any RegionMonitoring)?
    @ObservationIgnored let source: any CalendarDataSource
    @ObservationIgnored let settings: ArrivalAlertSettings
    @ObservationIgnored let notificationSettings: NotificationSettings
    @ObservationIgnored let visibilityStorage: CalendarVisibilityStorage
    @ObservationIgnored let preferences: any ArrivalAlertEventPreferences
    @ObservationIgnored let resolver: EventCoordinateResolver
    @ObservationIgnored let planner: ArrivalRegionPlanner
    @ObservationIgnored let notifier: any ArrivalNotifying
    @ObservationIgnored let log: ArrivalNotificationLog
    @ObservationIgnored let leaveBySettings: LeaveBySettings
    @ObservationIgnored let leaveByPlanner: LeaveByPlanner
    @ObservationIgnored let leaveAlertSettings: LeaveAlertSettings
    @ObservationIgnored let estimator: any TravelTimeEstimating
    @ObservationIgnored public var onLeaveByChange: (@MainActor () -> Void)?
    @ObservationIgnored let clock: @Sendable () -> Date
    @ObservationIgnored private var replanLoop: Task<Void, Never>?
    @ObservationIgnored private var needsReplan = false
    @ObservationIgnored var arrivalObservation: Task<Void, Never>?

    public init(
        capabilities: PlatformCapabilities,
        makeRegionMonitor: @MainActor () -> any RegionMonitoring = { CoreLocationRegionMonitor() },
        source: any CalendarDataSource = EventKitDataSource.shared,
        settings: ArrivalAlertSettings = ArrivalAlertSettings(),
        notificationSettings: NotificationSettings = NotificationSettings(),
        visibilityStorage: CalendarVisibilityStorage = CalendarVisibilityStorage(),
        preferences: any ArrivalAlertEventPreferences = ArrivalAlertPreferences(),
        resolver: EventCoordinateResolver = EventCoordinateResolver(),
        planner: ArrivalRegionPlanner = ArrivalRegionPlanner(),
        notifier: any ArrivalNotifying = UserNotificationArrivalNotifier(),
        log: ArrivalNotificationLog = ArrivalNotificationLog(),
        leaveBySettings: LeaveBySettings = LeaveBySettings(),
        leaveByPlanner: LeaveByPlanner = LeaveByPlanner(),
        leaveAlertSettings: LeaveAlertSettings = LeaveAlertSettings(),
        estimator: any TravelTimeEstimating = MapKitTravelTimeEstimator(),
        clock: @escaping @Sendable () -> Date = { .now }
    ) {
        isSupported = capabilities.supports(.geofencedNotifications)
        regionMonitor = isSupported ? makeRegionMonitor() : nil
        self.source = source
        self.settings = settings
        self.notificationSettings = notificationSettings
        self.visibilityStorage = visibilityStorage
        self.preferences = preferences
        self.resolver = resolver
        self.planner = planner
        self.notifier = notifier
        self.log = log
        self.leaveBySettings = leaveBySettings
        self.leaveByPlanner = leaveByPlanner
        self.leaveAlertSettings = leaveAlertSettings
        self.estimator = estimator
        self.clock = clock
        isEnabled = isSupported && settings.isEnabled
        isLeaveByEnabled = isSupported && leaveBySettings.isEnabled
        authorization = regionMonitor?.authorization ?? .notDetermined
        regionMonitor?.onAuthorizationChange = { [weak self] in
            guard let self else { return }
            authorization = regionMonitor?.authorization ?? .notDetermined
            Task { await self.replan() }
        }
    }

    var isActive: Bool {
        isEnabled && notificationSettings.isEnabled && authorization.allowsMonitoring
    }

    /// Leave By only works out a route when iOS can wake Folio on arrival, which takes Always.
    var isLeaveByActive: Bool {
        leaveByStatus == .tracking
    }

    var leaveByStatus: LeaveByStatus {
        guard isLeaveByEnabled else { return .off }
        return authorization == .always ? .tracking : .needsAlwaysLocation
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
        guard let regionMonitor else { return }
        authorization = regionMonitor.authorization
        let now = clock()
        updateLeaveByStatus()
        let regions = isActive || isLeaveByActive
            ? planner.regions(
                for: await candidates(after: now),
                now: now,
                currentCoordinate: regionMonitor.lastKnownCoordinate
            )
            : []
        let desired = Set(regions.map(\.id))
        let monitored = await regionMonitor.monitoredIdentifiers()
        for identifier in monitored where !desired.contains(identifier) {
            await regionMonitor.stopMonitoring(identifier)
        }
        for region in regions where !monitored.contains(region.id) {
            await regionMonitor.startMonitoring(region)
        }
        monitoredRegions = regions
        arrivalLog.info("Monitoring \(regions.count) arrival regions")
    }

    /// Location access often changes in the Settings app after Leave By is turned on, so the widget is
    /// reloaded here rather than only when the toggle changes.
    private func updateLeaveByStatus() {
        let status = leaveByStatus
        guard leaveBySettings.status != status else { return }
        leaveBySettings.status = status
        onLeaveByChange?()
    }

    private func candidates(after now: Date) async -> [ArrivalCandidate] {
        let interval = DateInterval(start: now.addingTimeInterval(-planner.window.lag), duration: Self.lookAhead)
        let hiddenCalendars = visibilityStorage.hiddenCalendarIdentifiers
        let hiddenInvitations = visibilityStorage.hiddenInvitationIdentifiers
        var candidates: [ArrivalCandidate] = []
        let events = await source.flexTimeEvents(in: interval).filter {
            !hiddenCalendars.contains($0.calendarIdentifier)
                && !$0.isHiddenInvitation(among: hiddenInvitations)
                && (isLeaveByActive || preferences.isEnabled(for: $0.reference))
        }
        for event in EventDuplicateDetector().groups(in: events).map(\.primary) {
            guard planner.window.interval(for: event).map({ $0.end > now }) == true,
                  let coordinate = await resolver.coordinate(for: event),
                  let candidate = planner.candidate(for: event, at: coordinate) else { continue }
            candidates.append(candidate)
        }
        return candidates
    }
}
