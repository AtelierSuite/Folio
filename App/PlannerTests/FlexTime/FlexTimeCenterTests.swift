import Foundation
import Testing
@testable import Planner

@MainActor
struct FlexTimeCenterTests {
    private typealias Fixture = FlexTimeFixtures
    private let today = DateInterval(start: FlexTimeFixtures.time(0), end: FlexTimeFixtures.time(0, day: 32))

    private func makeCenter(
        now: Date = FlexTimeFixtures.time(10, 30),
        events: [CalendarEvent] = FlexTimeFixtures.morningEvents,
        sleepSamples: [SleepSample]? = nil,
        holidays: [Holiday] = []
    ) -> (center: FlexTimeCenter, store: CalendarStore) {
        let defaults = Fixture.makeDefaults()
        let storage = FlexTimeStorage(defaults: defaults)
        let store = CalendarStore(
            source: FakeCalendarDataSource(events: events),
            policy: CacheWindowPolicy(paddingWeeks: 1, calendar: Fixtures.calendar),
            visibilityStorage: CalendarVisibilityStorage(defaults: defaults),
            flexTimeStorage: storage
        )
        let preferences = SleepPreferences(suiteName: "FlexTimeCenterTests.\(UUID().uuidString)")
        preferences.informsFlexTime = sleepSamples != nil
        let sleepStore = SleepStore(
            source: FakeSleepDataSource(samples: sleepSamples ?? []),
            capabilities: PlatformCapabilities(platform: .iPhone, areLiveActivitiesSupported: true),
            preferences: preferences
        )
        let center = FlexTimeCenter(
            store: store,
            sleepStore: sleepStore,
            storage: storage,
            workWeekStorage: WorkWeekStorage(defaults: defaults),
            holidaySource: { holidays.isEmpty ? nil : .govUK },
            loadHolidays: { _ in holidays },
            clock: { now },
            calendar: { Fixtures.calendar }
        )
        return (center, store)
    }

    @Test func firstOpenOnAWeekendAfterTheFirstEventPromptsOnce() async throws {
        let (center, _) = makeCenter()
        await center.appDidBecomeActive()
        let proposal = try #require(center.prompt?.proposal)
        #expect(proposal.wake == FlexTimeWake(time: Fixture.time(10, 30), source: .firstOpen))
        #expect(proposal.suggestedStart == Fixture.time(11))

        center.dismissPrompt()
        await center.appDidBecomeActive()
        #expect(center.prompt == nil)
    }

    @Test func weekdaysOnlyPromptWhenTurnedOn() async {
        let events = [Fixtures.event(local: "standup", start: Fixture.time(8, day: 30))]
        let (center, _) = makeCenter(now: Fixture.time(10, 30, day: 30), events: events)
        await center.appDidBecomeActive()
        #expect(center.prompt == nil)

        center.setEnabled(true, on: .weekday)
        await center.appDidBecomeActive()
        #expect(center.prompt?.proposal != nil)
    }

    @Test func publicHolidayOnAWorkDayPrompts() async {
        let events = [Fixtures.event(local: "parade", start: Fixture.time(8, day: 30))]
        let holiday = Holiday(day: HolidayDay(year: 2026, month: 10, day: 30), name: "Holiday")
        let (center, _) = makeCenter(now: Fixture.time(10, 30, day: 30), events: events, holidays: [holiday])
        await center.appDidBecomeActive()
        #expect(center.prompt?.proposal != nil)
    }

    @Test func sleepThatEndedBeforeTheFirstEventDoesNotPrompt() async {
        let samples = [
            SleepFixtures.sample(.core, Fixture.time(23, day: 30), Fixture.time(7), SleepFixtures.watch)
        ]
        let (center, _) = makeCenter(sleepSamples: samples)
        await center.appDidBecomeActive()
        #expect(center.prompt == nil)
    }

    @Test func sleepEndingAfterTheFirstEventIsTheWakeTime() async throws {
        let samples = [
            SleepFixtures.sample(.core, Fixture.time(2), Fixture.time(10, 30), SleepFixtures.watch)
        ]
        let (center, _) = makeCenter(now: Fixture.time(10, 50), sleepSamples: samples)
        await center.appDidBecomeActive()
        let proposal = try #require(center.prompt?.proposal)
        #expect(proposal.wake == FlexTimeWake(time: Fixture.time(10, 30), source: .sleep))
        #expect(proposal.suggestedStart == Fixture.time(11))
    }

    @Test func delayingMovesTheDaysEventsUntilTurnedOff() async throws {
        let (center, store) = makeCenter()
        await center.appDidBecomeActive()
        let proposal = try #require(center.prompt?.proposal)
        let revision = store.contentRevision
        await center.delay(proposal, startingFirstEventAt: Fixture.time(11))
        #expect(center.prompt == nil)
        #expect(center.todayDelay == 3 * 3600)
        #expect(store.contentRevision == revision + 1)
        #expect(await store.events(in: today).map(\.startDate)
            == [Fixture.time(11), Fixture.time(13), Fixture.time(15, 30)])
        #expect(await store.scheduledEvents(in: today).map(\.startDate)
            == [Fixture.time(8), Fixture.time(10), Fixture.time(12, 30)])

        await center.presentForToday()
        #expect(center.prompt?.proposal?.isActive == true)
        await center.turnOff()
        #expect(center.todayDelay == 0)
        #expect(await store.events(in: today).map(\.startDate)
            == [Fixture.time(8), Fixture.time(10), Fixture.time(12, 30)])
    }

    @Test func askingOnADayWithoutEventsShowsTheEmptyState() async throws {
        let (center, _) = makeCenter(events: [])
        await center.appDidBecomeActive()
        #expect(center.prompt == nil)
        await center.presentForToday()
        let prompt = try #require(center.prompt)
        #expect(prompt.proposal == nil)
    }
}
