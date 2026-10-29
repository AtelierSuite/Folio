import Foundation
import Observation

@MainActor
@Observable
public final class NotificationScheduler {
    public internal(set) var authorization: NotificationAuthorization = .notDetermined
    public internal(set) var isEnabled: Bool
    public internal(set) var includesEvents: Bool
    public internal(set) var includesReminders: Bool
    public internal(set) var alarmAuthorization: NotificationAuthorization = .notDetermined
    public private(set) var lastReport: NotificationReplanReport?

    @ObservationIgnored let source: any CalendarDataSource
    @ObservationIgnored let center: any NotificationCenterClient
    @ObservationIgnored let alarmClient: any AlarmSchedulingClient
    @ObservationIgnored let alarmLedger: AlarmLedger
    @ObservationIgnored let settings: NotificationSettings
    @ObservationIgnored public let styleSettings: NotificationStyleSettings
    @ObservationIgnored public let capabilities: PlatformCapabilities
    @ObservationIgnored let visibilityStorage: CalendarVisibilityStorage
    @ObservationIgnored let planner: NotificationPlanner
    @ObservationIgnored let horizon: NotificationHorizon
    @ObservationIgnored let clock: @Sendable () -> Date
    @ObservationIgnored private var replanLoop: Task<Void, Never>?
    @ObservationIgnored private var needsReplan = false
    @ObservationIgnored var changeObservation: Task<Void, Never>?
    @ObservationIgnored var debouncedReplan: Task<Void, Never>?
    @ObservationIgnored var periodicReplanning: Task<Void, Never>?

    public init(
        source: any CalendarDataSource = EventKitDataSource.shared,
        center: any NotificationCenterClient = UserNotificationCenterClient(),
        alarmClient: (any AlarmSchedulingClient)? = nil,
        alarmLedger: AlarmLedger = AlarmLedger(),
        settings: NotificationSettings = NotificationSettings(),
        styleSettings: NotificationStyleSettings = .shared,
        capabilities: PlatformCapabilities = .current,
        visibilityStorage: CalendarVisibilityStorage = CalendarVisibilityStorage(),
        planner: NotificationPlanner? = nil,
        horizon: NotificationHorizon = NotificationHorizon(),
        clock: @escaping @Sendable () -> Date = { .now }
    ) {
        self.source = source
        self.center = center
        self.alarmClient = alarmClient ?? DefaultAlarmClient.make(capabilities: capabilities)
        self.alarmLedger = alarmLedger
        self.settings = settings
        self.styleSettings = styleSettings
        self.capabilities = capabilities
        self.visibilityStorage = visibilityStorage
        let resolver = NotificationStyleResolver(settings: styleSettings, capabilities: capabilities)
        self.planner = planner ?? NotificationPlanner(styleResolver: resolver.style(for:))
        self.horizon = horizon
        self.clock = clock
        isEnabled = settings.isEnabled
        includesEvents = settings.includesEvents
        includesReminders = settings.includesReminders
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
        authorization = await center.authorization()
        alarmAuthorization = await alarmClient.authorization()
        let pendingIdentifiers = await center.pendingIdentifiers()
        let foreignCount = pendingIdentifiers.count(where: { !NotificationIdentifier.isOwned($0) })
        let budget = planner.budget(foreignPendingCount: foreignCount)
        let now = clock()
        let plan = isEnabled && authorization.allowsScheduling
            ? await plan(after: now, budget: budget)
            : .empty
        let diff = NotificationPlanDiff(planned: plan.notifications, pendingIdentifiers: pendingIdentifiers)
        await center.removePending(withIdentifiers: diff.identifiersToRemove)
        var addedCount = 0
        for notification in diff.notificationsToAdd where (try? await center.add(notification, now: now)) != nil {
            addedCount += 1
        }
        let alarmCount = await replanAlarms(plan.alarms)
        let scheduledCount = plan.notifications.count - diff.notificationsToAdd.count + addedCount
        lastReport = NotificationReplanReport(
            date: now,
            budget: budget,
            scheduledCount: scheduledCount,
            pendingCount: foreignCount + scheduledCount,
            addedCount: addedCount,
            removedCount: diff.identifiersToRemove.count,
            alarmCount: alarmCount,
            nextFireDate: plan.nextFireDate
        )
    }

    private func plan(after now: Date, budget: Int) async -> NotificationPlan {
        let hiddenCalendars = visibilityStorage.hiddenCalendarIdentifiers
        let events = includesEvents ? await source.events(in: horizon.eventInterval(from: now)) : []
        let reminders = includesReminders
            ? await source.reminders(completedIn: DateInterval(start: now, duration: 0))
            : []
        return planner.plan(
            events: events.filter { !hiddenCalendars.contains($0.calendarIdentifier) },
            reminders: reminders.filter { !hiddenCalendars.contains($0.listIdentifier) },
            after: now,
            budget: budget,
            alarmBudget: alarmAuthorization.allowsScheduling ? NotificationPlanner.alarmLimit : nil
        )
    }
}
