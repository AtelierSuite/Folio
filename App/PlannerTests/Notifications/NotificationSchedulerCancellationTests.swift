import Foundation
import Testing
@testable import Planner

@MainActor
struct NotificationSchedulerCancellationTests {
    private func makeScheduler() throws -> NotificationScheduler {
        let suiteName = "NotificationSchedulerCancellationTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        return NotificationScheduler(
            source: FakeCalendarDataSource(events: [
                NotificationFixtures.event("standup", start: NotificationFixtures.hours(1))
            ]),
            center: FakeNotificationCenter(),
            alarmClient: FakeAlarmClient(),
            alarmLedger: AlarmLedger(defaults: defaults),
            settings: NotificationSettings(defaults: defaults),
            styleSettings: NotificationStyleSettings(defaults: defaults),
            capabilities: PlatformCapabilities(platform: .iPhone, areLiveActivitiesSupported: true),
            visibilityStorage: CalendarVisibilityStorage(defaults: defaults),
            planner: NotificationFixtures.planner(),
            clock: { NotificationFixtures.now }
        )
    }

    @Test func aCancelledBackgroundReplanSkipsTheDependentFeatures() async throws {
        let scheduler = try makeScheduler()
        var dependentReplans = 0
        scheduler.didReplan = { dependentReplans += 1 }
        let refresh = Task { await scheduler.replan(stopsWhenCancelled: true) }
        refresh.cancel()
        await refresh.value
        #expect(dependentReplans == 0)
        await scheduler.replan()
        #expect(dependentReplans == 1)
    }

    @Test func anOrdinaryReplanFinishesWhenItsCallerIsCancelled() async throws {
        let scheduler = try makeScheduler()
        var dependentReplans = 0
        scheduler.didReplan = { dependentReplans += 1 }
        let caller = Task { await scheduler.replan() }
        caller.cancel()
        await caller.value
        #expect(dependentReplans == 1)
        #expect(scheduler.lastReport != nil)
    }

    @Test func cancellableStepsStopBeforeTheNextStep() async {
        var finished: [String] = []
        let task = Task {
            await CancellableSteps.run([
                { finished.append("arrival") },
                { withUnsafeCurrentTask { $0?.cancel() } },
                { finished.append("leave") }
            ])
        }
        await task.value
        #expect(finished == ["arrival"])
    }
}
