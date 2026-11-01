import Foundation
import Testing
@testable import Planner

@MainActor
struct NotificationSoundTests {
    private let work = NotificationFixtures.event("work", start: NotificationFixtures.hours(1))
    private let milk = NotificationFixtures.reminder("milk", due: NotificationFixtures.hours(2))

    private func makeScheduler(defaults: UserDefaults, center: FakeNotificationCenter) -> NotificationScheduler {
        let settings = NotificationSettings(defaults: defaults)
        settings.isEnabled = true
        return NotificationScheduler(
            source: FakeCalendarDataSource(events: [work], reminders: [milk]),
            center: center,
            alarmClient: FakeAlarmClient(authorization: .denied),
            alarmLedger: AlarmLedger(defaults: defaults),
            settings: settings,
            soundSettings: NotificationSoundSettings(defaults: defaults),
            styleSettings: NotificationStyleSettings(defaults: defaults),
            allDayAlertTimeSettings: AllDayAlertTimeSettings(defaults: defaults),
            capabilities: PlatformCapabilities(platform: .iPhone, areLiveActivitiesSupported: false),
            visibilityStorage: CalendarVisibilityStorage(defaults: defaults),
            clock: { NotificationFixtures.now }
        )
    }

    @Test func eachKindOffersTheSystemSoundAndItsOwnTen() {
        let eventChoices = NotificationSound.choices(for: .event)
        let reminderChoices = NotificationSound.choices(for: .reminder)
        #expect(eventChoices.count == 11 && reminderChoices.count == 11)
        #expect(eventChoices.first == .system && reminderChoices.first == .system)
        #expect(Set(eventChoices).intersection(reminderChoices) == [.system])
        #expect(NotificationSound.system.fileName == nil)
        #expect(NotificationSound.furin.fileName == "Calendar-Furin.caf")
    }

    @Test func soundsAreStoredPerKind() throws {
        let defaults = try #require(UserDefaults(suiteName: "NotificationSoundTests.\(UUID().uuidString)"))
        let settings = NotificationSoundSettings(defaults: defaults)
        #expect(settings.sound(for: .event) == .system)
        settings.setSound(.asahi, for: .event)
        settings.setSound(.tsuki, for: .reminder)
        #expect(settings.sound(for: .event) == .asahi)
        #expect(settings.sound(for: .reminder) == .tsuki)
        settings.setSound(.system, for: .event)
        #expect(defaults.string(forKey: NotificationSoundSettings.eventSoundKey) == nil)
    }

    @Test func systemSoundKeepsExistingIdentifiers() {
        let candidate = NotificationCandidate(
            fireDate: NotificationFixtures.now, kind: .event, reference: work.reference,
            content: NotificationContent(title: "work", body: "")
        )
        let silent = PlannedNotification(candidate)
        #expect(silent.id == PlannedNotification(candidate, sound: .system).id)
        #expect(silent.id != PlannedNotification(candidate, sound: .furin).id)
        #expect(PlannedNotification(candidate, sound: .furin).restyled(.standard).sound == .furin)
    }

    @Test func changingASoundReschedulesOnlyThatKind() async throws {
        let defaults = try #require(UserDefaults(suiteName: "NotificationSoundTests.\(UUID().uuidString)"))
        let center = FakeNotificationCenter()
        let scheduler = makeScheduler(defaults: defaults, center: center)
        await scheduler.replan()
        #expect(center.pendingNotifications.map(\.sound) == [.system, .system])

        await scheduler.setSound(.uguisu, for: .event)
        await scheduler.setSound(.shizuku, for: .reminder)
        #expect(sounds(in: center) == [.event: .uguisu, .reminder: .shizuku])
        #expect(makeScheduler(defaults: defaults, center: center).sound(for: .event) == .uguisu)
    }

    @Test func calendarSoundsOverrideTheirKindAndFallBackWhenCleared() async throws {
        let defaults = try #require(UserDefaults(suiteName: "NotificationSoundTests.\(UUID().uuidString)"))
        let center = FakeNotificationCenter()
        let scheduler = makeScheduler(defaults: defaults, center: center)
        await scheduler.setSound(.uguisu, for: .event)
        await scheduler.setSound(.hotaru, for: .reminder)
        await scheduler.setSound(.kumo, forCalendar: work.calendarIdentifier)
        await scheduler.setSound(.tsuki, forCalendar: milk.listIdentifier)
        #expect(sounds(in: center) == [.event: .kumo, .reminder: .tsuki])
        #expect(makeScheduler(defaults: defaults, center: center).sound(forCalendar: work.calendarIdentifier) == .kumo)

        await scheduler.setSound(nil, forCalendar: work.calendarIdentifier)
        #expect(sounds(in: center) == [.event: .uguisu, .reminder: .tsuki])
        #expect(scheduler.sound(forCalendar: work.calendarIdentifier) == nil)
    }

    @Test func aCalendarSoundOnlyAppliesToItsOwnCalendar() throws {
        let defaults = try #require(UserDefaults(suiteName: "NotificationSoundTests.\(UUID().uuidString)"))
        let settings = NotificationSoundSettings(defaults: defaults)
        settings.setSound(.niji, forCalendar: "other-calendar")
        let candidate = NotificationCandidate(
            fireDate: NotificationFixtures.now, kind: .event, reference: work.reference,
            content: NotificationContent(title: "work", body: "")
        )
        #expect(settings.resolvedSound(for: candidate) == .system)
        settings.setSound(.system, forCalendar: work.calendarIdentifier)
        settings.setSound(.nami, for: .event)
        #expect(settings.resolvedSound(for: candidate) == .system)
    }

    private func sounds(in center: FakeNotificationCenter) -> [CalendarItemKind: NotificationSound] {
        Dictionary(uniqueKeysWithValues: center.pendingNotifications.map { ($0.kind, $0.sound) })
    }
}
