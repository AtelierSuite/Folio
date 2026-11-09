import Foundation
import Observation

@MainActor
@Observable
public final class WakeUpAlarmCenter {
    public let isSupported: Bool
    public internal(set) var isEnabled: Bool
    public internal(set) var leadMinutes: Int
    public internal(set) var earliestMinutes: Int
    public internal(set) var latestEventMinutes: Int
    public internal(set) var skipsHolidays: Bool
    public internal(set) var excludedCalendarIdentifiers: Set<String>
    public internal(set) var addsTravelTime: Bool
    public internal(set) var transport: TravelTransport
    public internal(set) var locationAuthorization: ArrivalAuthorization = .notDetermined
    /// Runs work started by a location change, which may have woken the app in the background.
    @ObservationIgnored public var performBackgroundWork: @MainActor (@escaping @MainActor () async -> Void) -> Void
        = { work in Task { await work() } }
    public internal(set) var authorization: NotificationAuthorization = .notDetermined
    public internal(set) var upcomingAlarms: [WakeUpAlarm] = []

    @ObservationIgnored let source: any CalendarDataSource
    @ObservationIgnored let settings: WakeUpAlarmSettings
    @ObservationIgnored let visibilityStorage: CalendarVisibilityStorage
    @ObservationIgnored let alarmClient: any AlarmSchedulingClient
    @ObservationIgnored let ledger: AlarmLedger
    @ObservationIgnored let formatter: NotificationContentFormatter
    @ObservationIgnored let loadHolidays: @Sendable (HolidaySource) async -> [Holiday]
    @ObservationIgnored let clock: @Sendable () -> Date
    @ObservationIgnored let locator: (any CurrentLocating)?
    @ObservationIgnored let resolver: EventCoordinateResolver
    @ObservationIgnored let estimator: any TravelTimeEstimating
    @ObservationIgnored let travelPlanner = TravelTimePlanner()
    @ObservationIgnored var cachedTravelTimes: [TravelTimeKey: CachedTravelTime] = [:]
    @ObservationIgnored let locationMonitor: (any SignificantLocationMonitoring)?
    @ObservationIgnored var recentOrigin: RecentOrigin?
    @ObservationIgnored var plannedOrigin: PlannerCoordinate?
    @ObservationIgnored var lastMovementReplan: Date?
    @ObservationIgnored private var replanLoop: Task<Void, Never>?
    @ObservationIgnored private var needsReplan = false

    public static let ledgerKey = "WakeUpAlarm.ScheduledAlarms"

    public init(
        capabilities: PlatformCapabilities,
        source: any CalendarDataSource = EventKitDataSource.shared,
        settings: WakeUpAlarmSettings = WakeUpAlarmSettings(),
        visibilityStorage: CalendarVisibilityStorage = CalendarVisibilityStorage(),
        alarmClient: (any AlarmSchedulingClient)? = nil,
        ledger: AlarmLedger = AlarmLedger(key: WakeUpAlarmCenter.ledgerKey),
        formatter: NotificationContentFormatter = NotificationContentFormatter(),
        loadHolidays: @escaping @Sendable (HolidaySource) async -> [Holiday] = {
            await HolidayRepository().holidays(for: $0)
        },
        clock: @escaping @Sendable () -> Date = { .now },
        locator: (any CurrentLocating)? = CurrentLocationProvider.shared,
        resolver: EventCoordinateResolver = EventCoordinateResolver(),
        estimator: any TravelTimeEstimating = MapKitTravelTimeEstimator(),
        makeLocationMonitor: @MainActor () -> any SignificantLocationMonitoring = {
            CoreLocationSignificantChangeMonitor()
        }
    ) {
        isSupported = capabilities.supports(.alarms)
        self.source = source
        self.settings = settings
        self.visibilityStorage = visibilityStorage
        self.alarmClient = alarmClient ?? DefaultAlarmClient.make(capabilities: capabilities)
        self.ledger = ledger
        self.formatter = formatter
        self.loadHolidays = loadHolidays
        self.clock = clock
        self.locator = locator
        self.resolver = resolver
        self.estimator = estimator
        locationMonitor = isSupported ? makeLocationMonitor() : nil
        isEnabled = isSupported && settings.isEnabled
        leadMinutes = settings.leadMinutes
        earliestMinutes = settings.earliestMinutes
        latestEventMinutes = settings.latestEventMinutes
        skipsHolidays = settings.skipsHolidays
        excludedCalendarIdentifiers = settings.excludedCalendarIdentifiers
        addsTravelTime = settings.addsTravelTime
        transport = settings.transport
        attachLocationMonitor()
    }

    func planner(skipping skippedDays: Set<HolidayDay> = []) -> WakeUpAlarmPlanner {
        WakeUpAlarmPlanner(
            leadTime: TimeInterval(leadMinutes * 60),
            earliestMinutes: earliestMinutes,
            latestEventMinutes: latestEventMinutes,
            skippedDays: skippedDays,
            calendar: formatter.calendar
        )
    }

    private func skippedHolidayDays() async -> Set<HolidayDay> {
        guard skipsHolidays, let source = settings.highlightedHolidaySource else { return [] }
        return Set(await loadHolidays(source).map(\.day))
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
        authorization = await alarmClient.authorization()
        var alarms: [WakeUpAlarm] = []
        if isEnabled && authorization.allowsScheduling {
            let now = clock()
            let hiddenCalendars = visibilityStorage.hiddenCalendarIdentifiers.union(excludedCalendarIdentifiers)
            let hiddenInvitations = visibilityStorage.hiddenInvitationIdentifiers
            let alarmPlanner = planner(skipping: await skippedHolidayDays())
            let events = await source.events(in: alarmPlanner.interval(after: now))
                .filter {
                    !hiddenCalendars.contains($0.calendarIdentifier) && !$0.isHiddenInvitation(among: hiddenInvitations)
                }
            let travelTimes = addsTravelTime
                ? await travelTimes(to: alarmPlanner.morningEvents(in: events, after: now), now: now)
                : [:]
            alarms = alarmPlanner.alarms(for: events, after: now, travelTimes: travelTimes)
        }
        let requests = alarms.map { $0.request(formatter: formatter) }
        let outcome = await AlarmSynchronizer(client: alarmClient, ledger: ledger).synchronize(requests)
        let failed = Set(outcome.failed.map(\.id))
        upcomingAlarms = zip(alarms, requests).filter { !failed.contains($0.1.id) }.map(\.0)
        settings.upcomingFireDates = upcomingAlarms.map(\.fireDate)
    }
}
