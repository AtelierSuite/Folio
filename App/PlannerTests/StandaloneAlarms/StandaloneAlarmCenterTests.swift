import Foundation
import Testing
@testable import Planner

@MainActor
struct StandaloneAlarmCenterTests {
    private let clock = MovableClock(Fixtures.date(2026, 11, 3, hour: 22))
    private let wakeTime = Fixtures.date(2026, 11, 4, hour: 7)

    private func makeCenter(
        alarms: FakeAlarmClient = FakeAlarmClient(),
        defaults: UserDefaults? = nil,
        platform: DevicePlatform = .iPhone
    ) throws -> StandaloneAlarmCenter {
        let suiteName = "StandaloneAlarmCenterTests.\(UUID().uuidString)"
        let defaults = try defaults ?? #require(UserDefaults(suiteName: suiteName))
        let clock = clock
        return StandaloneAlarmCenter(
            capabilities: PlatformCapabilities(platform: platform, areLiveActivitiesSupported: false),
            storage: StandaloneAlarmStorage(defaults: defaults),
            alarmClient: alarms,
            ledger: AlarmLedger(key: "Standalone", defaults: defaults),
            clock: { clock.now }
        )
    }

    @Test func addingSchedulesASnoozableAlarm() async throws {
        let alarms = FakeAlarmClient()
        let center = try makeCenter(alarms: alarms)
        #expect(await center.add(at: wakeTime, label: "Gym") == .scheduled)
        let scheduled = try #require(alarms.scheduledAlarms.first)
        #expect(scheduled.fireDate == wakeTime)
        #expect(scheduled.title == "Gym")
        #expect(scheduled.item == nil)
        #expect(scheduled.secondaryAction == .snooze(AlarmSnoozeSettings().duration))
        #expect(center.alarms.map(\.fireDate) == [wakeTime])
    }

    @Test func anAlarmCanSnoozeForItsOwnTime() async throws {
        let alarms = FakeAlarmClient()
        let center = try makeCenter(alarms: alarms)
        _ = await center.add(at: wakeTime, label: "Gym", snoozeMinutes: 3)
        #expect(alarms.scheduledAlarms.map(\.secondaryAction) == [.snooze(3 * 60)])
    }

    @Test func changingAnAlarmsSnoozeReschedulesIt() async throws {
        let alarms = FakeAlarmClient()
        let center = try makeCenter(alarms: alarms)
        _ = await center.add(at: wakeTime, label: "Gym")
        let alarm = try #require(center.alarms.first)
        await center.setSnoozeMinutes(15, for: alarm)
        #expect(alarms.scheduledCount == 1)
        #expect(alarms.scheduledAlarms.map(\.secondaryAction) == [.snooze(15 * 60)])
        #expect(center.alarms.map(\.snoozeMinutes) == [15])
        await center.setSnoozeMinutes(nil, for: try #require(center.alarms.first))
        #expect(alarms.scheduledAlarms.map(\.secondaryAction) == [.snooze(AlarmSnoozeSettings().duration)])
    }

    @Test func anAlarmRingsWithItsChosenSound() async throws {
        let alarms = FakeAlarmClient()
        let center = try makeCenter(alarms: alarms)
        _ = await center.add(at: wakeTime, label: "Gym", sound: .hibari)
        #expect(alarms.scheduledAlarms.map(\.sound) == [.hibari])
    }

    @Test func changingAnAlarmsSoundReplacesTheScheduledAlarm() async throws {
        let alarms = FakeAlarmClient()
        let center = try makeCenter(alarms: alarms)
        _ = await center.add(at: wakeTime, label: "Gym", snoozeMinutes: 5)
        let original = try #require(center.alarms.first)
        await center.setSound(.kaminari, for: original)
        let replaced = try #require(center.alarms.first)
        #expect(center.alarms.count == 1)
        #expect(replaced.id != original.id)
        #expect(replaced.label == "Gym")
        #expect(replaced.snoozeMinutes == 5)
        #expect(alarms.scheduledCount == 1)
        #expect(alarms.scheduledAlarms.map(\.id) == [replaced.id])
        #expect(alarms.scheduledAlarms.map(\.sound) == [.kaminari])
    }

    @Test func anEmptyLabelFallsBackToADefaultTitle() async throws {
        let alarms = FakeAlarmClient()
        let center = try makeCenter(alarms: alarms)
        _ = await center.add(at: wakeTime, label: "  ")
        #expect(alarms.scheduledAlarms.first?.title.isEmpty == false)
    }

    @Test func alarmsPersistAcrossLaunches() async throws {
        let defaults = try #require(UserDefaults(suiteName: "StandaloneAlarmCenterTests.\(UUID().uuidString)"))
        let alarms = FakeAlarmClient()
        let firstLaunch = try makeCenter(alarms: alarms, defaults: defaults)
        _ = await firstLaunch.add(at: wakeTime, label: "Gym")
        let relaunched = try makeCenter(alarms: alarms, defaults: defaults)
        #expect(relaunched.alarms.map(\.label) == ["Gym"])
        await relaunched.replan()
        #expect(alarms.scheduledCount == 1)
    }

    @Test func removingCancelsOnlyThatAlarm() async throws {
        let foreign = UUID()
        let alarms = FakeAlarmClient(foreignIdentifiers: [foreign])
        let center = try makeCenter(alarms: alarms)
        _ = await center.add(at: wakeTime, label: "First")
        _ = await center.add(at: wakeTime.addingTimeInterval(600), label: "Second")
        let first = try #require(center.alarms.first)
        await center.remove(first)
        let second = try #require(center.alarms.first)
        #expect(second.label == "Second")
        #expect(Set(await alarms.scheduledIdentifiers()) == [foreign, second.id])
    }

    @Test func rungAlarmsAreDroppedWithoutCancellingASnooze() async throws {
        let alarms = FakeAlarmClient()
        let center = try makeCenter(alarms: alarms)
        _ = await center.add(at: wakeTime, label: "Gym")
        clock.move(to: wakeTime.addingTimeInterval(60))
        await center.replan()
        #expect(center.alarms.isEmpty)
        #expect(alarms.cancelCount == 0)
        #expect(alarms.scheduleCount == 1)
    }

    @Test func pastTimesAreRefused() async throws {
        let alarms = FakeAlarmClient()
        let center = try makeCenter(alarms: alarms)
        #expect(await center.add(at: Fixtures.date(2026, 11, 3, hour: 8), label: "") == .pastDate)
        #expect(alarms.scheduledCount == 0)
    }

    @Test func deniedPermissionSavesNothing() async throws {
        let alarms = FakeAlarmClient(authorization: .denied)
        let center = try makeCenter(alarms: alarms)
        #expect(await center.add(at: wakeTime, label: "") == .denied)
        #expect(center.alarms.isEmpty)
        #expect(center.authorization == .denied)
    }

    @Test func anAlarmAlarmKitRefusesIsNotKept() async throws {
        let alarms = FakeAlarmClient()
        alarms.setLimit(0)
        let center = try makeCenter(alarms: alarms)
        #expect(await center.add(at: wakeTime, label: "") == .failed)
        #expect(center.alarms.isEmpty)
    }

    @Test func listsAlarmsInAnInterval() async throws {
        let center = try makeCenter()
        _ = await center.add(at: wakeTime, label: "Tomorrow")
        _ = await center.add(at: wakeTime.addingTimeInterval(86_400), label: "Later")
        let tomorrow = DateInterval(start: Fixtures.date(2026, 11, 4), duration: 86_400)
        #expect(center.alarms(in: tomorrow).map(\.label) == ["Tomorrow"])
    }

    @Test func macDoesNotSupportStandaloneAlarms() async throws {
        let center = try makeCenter(platform: .mac)
        #expect(!center.isSupported)
        #expect(await center.add(at: wakeTime, label: "") == .failed)
    }
}
