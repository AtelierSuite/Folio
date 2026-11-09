import Foundation
import Testing
@testable import Planner

@MainActor
struct LeaveByTests {
    private struct Harness {
        let center: ArrivalAlertCenter
        let monitor: FakeRegionMonitor
        let notifier: RecordingArrivalNotifier
        let settings: LeaveBySettings
        let estimator: CountingTravelTimeEstimator
    }

    private final class CountingTravelTimeEstimator: TravelTimeEstimating, @unchecked Sendable {
        var result: TimeInterval? = 1500
        var error: Error?
        var requestCount = 0
        var lastOrigin: PlannerCoordinate?

        func travelTime(
            from origin: PlannerCoordinate,
            to destination: PlannerCoordinate,
            by transport: TravelTransport,
            arrivingAt arrivalDate: Date
        ) async throws -> TimeInterval? {
            requestCount += 1
            lastOrigin = origin
            if let error { throw error }
            return result
        }
    }

    private let here = ArrivalFixtures.coordinate(0)
    private let elsewhere = ArrivalFixtures.coordinate(1)

    private var lunchThenDentist: [CalendarEvent] {
        [event("Lunch", hours: 0.5, at: here), event("Dentist", hours: 3, at: elsewhere)]
    }

    private func event(_ title: String, hours: Double, at coordinate: PlannerCoordinate?) -> CalendarEvent {
        ArrivalFixtures.event(title, start: ArrivalFixtures.hours(hours), coordinate: coordinate)
    }

    private func makeHarness(
        events: [CalendarEvent],
        authorization: ArrivalAuthorization = .always,
        isEnabled: Bool = true,
        alertEvents: [CalendarEvent] = []
    ) throws -> Harness {
        let defaults = try #require(UserDefaults(suiteName: "LeaveByTests.\(UUID().uuidString)"))
        let notificationSettings = NotificationSettings(defaults: defaults)
        notificationSettings.isEnabled = true
        let arrivalSettings = ArrivalAlertSettings(defaults: defaults)
        arrivalSettings.isEnabled = true
        let settings = LeaveBySettings(defaults: defaults)
        settings.isEnabled = isEnabled
        let monitor = FakeRegionMonitor(authorization: authorization)
        let notifier = RecordingArrivalNotifier()
        let estimator = CountingTravelTimeEstimator()
        let center = ArrivalAlertCenter(
            capabilities: PlatformCapabilities(platform: .iPhone, areLiveActivitiesSupported: false),
            makeRegionMonitor: { monitor },
            source: FakeCalendarDataSource(events: events),
            settings: arrivalSettings,
            notificationSettings: notificationSettings,
            visibilityStorage: CalendarVisibilityStorage(defaults: defaults),
            preferences: InMemoryArrivalPreferences(enabled: Set(alertEvents.map(\.reference.storageKey))),
            resolver: EventCoordinateResolver(geocoder: FakeGeocoder(), cache: InMemoryGeocodeCache()),
            notifier: notifier,
            log: ArrivalNotificationLog(defaults: defaults),
            leaveBySettings: settings,
            leaveAlertSettings: LeaveAlertSettings(defaults: defaults),
            estimator: estimator,
            clock: { ArrivalFixtures.now }
        )
        return Harness(center: center, monitor: monitor, notifier: notifier, settings: settings, estimator: estimator)
    }

    private func arrive(_ harness: Harness, at coordinate: PlannerCoordinate) async {
        await harness.center.replan()
        await harness.center.handle(
            RegionArrival(identifier: ArrivalRegion.identifier(for: coordinate), date: ArrivalFixtures.now)
        )
    }

    @Test func worksOutTheRouteToTheNextEventOnArrival() async throws {
        let next = event("Dentist", hours: 3, at: elsewhere)
        let harness = try makeHarness(events: [event("Lunch", hours: 0.5, at: here), next])
        await arrive(harness, at: here)
        #expect(harness.settings.plan?.eventKey == next.reference.storageKey)
        #expect(harness.settings.plan?.travelTime == 1500)
        #expect(harness.estimator.lastOrigin == here)
    }

    @Test func calculatesOncePerEventReached() async throws {
        let harness = try makeHarness(events: lunchThenDentist)
        await arrive(harness, at: here)
        await arrive(harness, at: here)
        #expect(harness.estimator.requestCount == 1)
    }

    @Test func triesAgainAfterARouteFails() async throws {
        let harness = try makeHarness(events: lunchThenDentist)
        harness.estimator.error = CancellationError()
        await arrive(harness, at: here)
        #expect(harness.settings.plan == nil)
        harness.estimator.error = nil
        await arrive(harness, at: here)
        #expect(harness.settings.plan != nil)
    }

    @Test func needsNoPlanWhenTheNextEventIsInTheSamePlace() async throws {
        let events = [event("Lunch", hours: 0.5, at: here), event("Coffee", hours: 2, at: here)]
        let harness = try makeHarness(events: events)
        await arrive(harness, at: here)
        #expect(harness.settings.plan == nil)
        #expect(harness.estimator.requestCount == 0)
    }

    @Test func looksPastEventsHereAndEventsWithNoPlace() async throws {
        let next = event("Dentist", hours: 5, at: elsewhere)
        let harness = try makeHarness(events: [
            event("Lunch", hours: 0.5, at: here),
            event("Coffee", hours: 2, at: here),
            event("Call", hours: 3, at: nil),
            next
        ])
        await arrive(harness, at: here)
        #expect(harness.settings.plan?.eventKey == next.reference.storageKey)
    }

    @Test func clearsAnOldPlanWhenThereIsNowhereToGo() async throws {
        let harness = try makeHarness(events: [event("Lunch", hours: 0.5, at: here)])
        harness.settings.plan = LeaveByPlan(eventKey: "old", travelTime: 60, transport: .driving)
        await arrive(harness, at: here)
        #expect(harness.settings.plan == nil)
    }

    @Test func monitorsEveryLocatedEventWithoutItsOwnArrivalAlert() async throws {
        let harness = try makeHarness(events: lunchThenDentist)
        await harness.center.replan()
        #expect(harness.monitor.monitored.count == 2)
    }

    @Test func doesNotAlertForEventsMonitoredOnlyForLeaveBy() async throws {
        let harness = try makeHarness(events: lunchThenDentist)
        await arrive(harness, at: here)
        #expect(harness.notifier.notifiedTitles.isEmpty)
    }

    @Test func stillAlertsForEventsThatAskedForIt() async throws {
        let lunch = event("Lunch", hours: 0.5, at: here)
        let harness = try makeHarness(events: [lunch, event("Dentist", hours: 3, at: elsewhere)], alertEvents: [lunch])
        await arrive(harness, at: here)
        #expect(harness.notifier.notifiedTitles == ["Lunch"])
    }

    @Test func needsAlwaysLocationAccess() async throws {
        let harness = try makeHarness(
            events: [event("Lunch", hours: 0.5, at: here), event("Dentist", hours: 3, at: elsewhere)],
            authorization: .whenInUse
        )
        await arrive(harness, at: here)
        #expect(harness.settings.plan == nil)
        #expect(harness.settings.status == .needsAlwaysLocation)
        #expect(harness.monitor.monitored.isEmpty)
    }

    @Test func turningOnAsksForLocationAndTurningOffForgetsThePlan() async throws {
        let harness = try makeHarness(events: [], isEnabled: false)
        await harness.center.setLeaveByEnabled(true)
        #expect(harness.monitor.authorizationRequestCount == 1)
        #expect(harness.settings.status == .tracking)
        harness.settings.plan = LeaveByPlan(eventKey: "old", travelTime: 60, transport: .driving)
        await harness.center.setLeaveByEnabled(false)
        #expect(harness.settings.plan == nil)
        #expect(harness.settings.status == .off)
    }

    @Test func reloadsTheWidgetWhenAlwaysIsAllowedLater() async throws {
        let harness = try makeHarness(events: [], authorization: .whenInUse, isEnabled: false)
        var reloadCount = 0
        harness.center.onLeaveByChange = { reloadCount += 1 }
        await harness.center.setLeaveByEnabled(true)
        #expect(harness.settings.status == .needsAlwaysLocation)
        reloadCount = 0
        harness.monitor.authorization = .always
        await harness.center.replan()
        #expect(harness.settings.status == .tracking)
        #expect(reloadCount == 1)
        await harness.center.replan()
        #expect(reloadCount == 1)
    }
}

struct WidgetLeaveByTests {
    private let start = Fixtures.date(2026, 11, 6, hour: 15)

    private func snapshot(rain: Double? = nil) -> WidgetSnapshot {
        let event = Fixtures.event(local: "dentist", start: start)
        return WidgetSnapshot(
            events: [event],
            leaveByPlan: LeaveByPlan(eventKey: event.reference.storageKey, travelTime: 1800, transport: .walking),
            leaveByRainChance: rain
        )
    }

    @Test func leavesTravelTimeBeforeTheEvent() {
        let leaveBy = snapshot().leaveBy(at: start.addingTimeInterval(-7200))
        #expect(leaveBy?.leaveDate == start.addingTimeInterval(-1800))
        #expect(leaveBy?.transport == .walking)
    }

    @Test func urgencyRisesAsLeavingGetsCloser() throws {
        let leaveBy = try #require(snapshot().leaveBy(at: start.addingTimeInterval(-7200)))
        #expect(leaveBy.urgency(at: start.addingTimeInterval(-7200)) == .relaxed)
        #expect(leaveBy.urgency(at: start.addingTimeInterval(-2400)) == .soon)
        #expect(leaveBy.urgency(at: start.addingTimeInterval(-600)) == .overdue)
    }

    @Test func goesAwayOnceTheEventStarts() {
        #expect(snapshot().leaveBy(at: start) == nil)
    }

    @Test func aPlanForAMissingEventShowsNothing() {
        let plan = LeaveByPlan(eventKey: "gone", travelTime: 60, transport: .driving)
        #expect(WidgetSnapshot(leaveByPlan: plan).leaveBy(at: start) == nil)
    }

    @Test func asksForAnUmbrellaWhenRainIsLikely() {
        let now = start.addingTimeInterval(-7200)
        #expect(snapshot(rain: 0.7).leaveBy(at: now)?.needsUmbrella == true)
        #expect(snapshot(rain: 0.1).leaveBy(at: now)?.needsUmbrella == false)
    }

    @Test func updatesEveryMinuteCloseToLeaving() throws {
        let now = start.addingTimeInterval(-7200)
        let leaveBy = try #require(snapshot().leaveBy(at: now))
        let dates = leaveBy.timelineDates(after: now)
        #expect(dates.contains(leaveBy.leaveDate.addingTimeInterval(-60)))
        #expect(!dates.contains(now.addingTimeInterval(60)))
        #expect(dates.last == start)
    }

    @Test func dayLoadCountsTheJourneyAsBusy() {
        let now = start.addingTimeInterval(-7200)
        let status = snapshot().dayLoad(at: now, calendar: Fixtures.calendar).status
        #expect(status == .free(until: start.addingTimeInterval(-1800)))
    }
}
