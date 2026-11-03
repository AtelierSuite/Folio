import Foundation
import Observation

@MainActor
@Observable
public final class StandaloneAlarmCenter {
    public let isSupported: Bool
    public internal(set) var authorization: NotificationAuthorization = .notDetermined
    /// Upcoming alarms, soonest first.
    public internal(set) var alarms: [StandaloneAlarm] = []

    @ObservationIgnored let storage: StandaloneAlarmStorage
    @ObservationIgnored let alarmClient: any AlarmSchedulingClient
    @ObservationIgnored let ledger: AlarmLedger
    @ObservationIgnored let clock: @Sendable () -> Date
    @ObservationIgnored private var latestReplan: Task<Set<UUID>, Never>?

    public static let ledgerKey = "StandaloneAlarms.ScheduledAlarms"

    public init(
        capabilities: PlatformCapabilities,
        storage: StandaloneAlarmStorage = StandaloneAlarmStorage(),
        alarmClient: (any AlarmSchedulingClient)? = nil,
        ledger: AlarmLedger = AlarmLedger(key: StandaloneAlarmCenter.ledgerKey),
        clock: @escaping @Sendable () -> Date = { .now }
    ) {
        isSupported = capabilities.supports(.alarms)
        self.storage = storage
        self.alarmClient = alarmClient ?? DefaultAlarmClient.make(capabilities: capabilities)
        self.ledger = ledger
        self.clock = clock
        alarms = storage.alarms.sorted { $0.fireDate < $1.fireDate }
    }

    public func alarms(in interval: DateInterval) -> [StandaloneAlarm] {
        alarms.filter { interval.start <= $0.fireDate && $0.fireDate < interval.end }
    }

    public func refreshAuthorization() async {
        authorization = await alarmClient.authorization()
    }

    public func add(at fireDate: Date, label: String) async -> StandaloneAlarmAddOutcome {
        guard isSupported else { return .failed }
        guard fireDate > clock() else { return .pastDate }
        if await alarmClient.authorization() == .notDetermined {
            _ = try? await alarmClient.requestAuthorization()
        }
        authorization = await alarmClient.authorization()
        guard authorization.allowsScheduling else { return .denied }
        let wholeMinute = (fireDate.timeIntervalSinceReferenceDate / 60).rounded(.down) * 60
        let alarm = StandaloneAlarm(fireDate: Date(timeIntervalSinceReferenceDate: wholeMinute), label: label)
        storage.alarms.append(alarm)
        let failed = await replan()
        guard failed.contains(alarm.id) else { return .scheduled }
        storage.alarms.removeAll { $0.id == alarm.id }
        await replan()
        return .failed
    }

    public func remove(_ alarm: StandaloneAlarm) async {
        storage.alarms.removeAll { $0.id == alarm.id }
        await replan()
    }

    /// Drops alarms that have rung and makes AlarmKit match the rest, returning the ones it refused.
    @discardableResult
    public func replan() async -> Set<UUID> {
        let previous = latestReplan
        let replan = Task {
            _ = await previous?.value
            return await performReplan()
        }
        latestReplan = replan
        return await replan.value
    }

    private func performReplan() async -> Set<UUID> {
        authorization = await alarmClient.authorization()
        let now = clock()
        let stored = storage.alarms
        let upcoming = stored.filter { $0.fireDate > now }.sorted { $0.fireDate < $1.fireDate }
        let rung = Set(stored.map(\.id)).subtracting(upcoming.map(\.id))
        if !rung.isEmpty {
            storage.alarms = upcoming
            // A rung alarm may still be snoozing, so stop owning it rather than cancel it.
            ledger.identifiers.subtract(rung)
        }
        let requests = authorization.allowsScheduling ? upcoming.map(\.request) : []
        let outcome = await AlarmSynchronizer(client: alarmClient, ledger: ledger).synchronize(requests)
        alarms = upcoming
        return Set(outcome.failed.map(\.id))
    }
}
