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
    public internal(set) var authorization: NotificationAuthorization = .notDetermined
    public internal(set) var upcomingAlarms: [WakeUpAlarm] = []

    @ObservationIgnored let source: any CalendarDataSource
    @ObservationIgnored let settings: WakeUpAlarmSettings
    @ObservationIgnored let visibilityStorage: CalendarVisibilityStorage
    @ObservationIgnored let alarmClient: any AlarmSchedulingClient
    @ObservationIgnored let ledger: AlarmLedger
    @ObservationIgnored let formatter: NotificationContentFormatter
    @ObservationIgnored let clock: @Sendable () -> Date
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
        clock: @escaping @Sendable () -> Date = { .now }
    ) {
        isSupported = capabilities.supports(.alarms)
        self.source = source
        self.settings = settings
        self.visibilityStorage = visibilityStorage
        self.alarmClient = alarmClient ?? DefaultAlarmClient.make(capabilities: capabilities)
        self.ledger = ledger
        self.formatter = formatter
        self.clock = clock
        isEnabled = isSupported && settings.isEnabled
        leadMinutes = settings.leadMinutes
        earliestMinutes = settings.earliestMinutes
        latestEventMinutes = settings.latestEventMinutes
    }

    var planner: WakeUpAlarmPlanner {
        WakeUpAlarmPlanner(
            leadTime: TimeInterval(leadMinutes * 60),
            earliestMinutes: earliestMinutes,
            latestEventMinutes: latestEventMinutes,
            calendar: formatter.calendar
        )
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
            let hiddenCalendars = visibilityStorage.hiddenCalendarIdentifiers
            let events = await source.events(in: planner.interval(after: now))
                .filter { !hiddenCalendars.contains($0.calendarIdentifier) }
            alarms = planner.alarms(for: events, after: now)
        }
        let requests = alarms.map { $0.request(formatter: formatter) }
        let outcome = await AlarmSynchronizer(client: alarmClient, ledger: ledger).synchronize(requests)
        let failed = Set(outcome.failed.map(\.id))
        upcomingAlarms = zip(alarms, requests).filter { !failed.contains($0.1.id) }.map(\.0)
    }
}
