import Foundation
import Observation

@MainActor
@Observable
public final class FlexTimeCenter {
    public internal(set) var enabledDayKinds: Set<FlexTimeDayKind>
    public internal(set) var prompt: FlexTimePrompt?
    public internal(set) var revision = 0

    @ObservationIgnored let storage: FlexTimeStorage
    @ObservationIgnored let store: CalendarStore
    @ObservationIgnored let sleepStore: SleepStore
    @ObservationIgnored let workWeekStorage: WorkWeekStorage
    @ObservationIgnored let holidaySource: @Sendable () -> HolidaySource?
    @ObservationIgnored let loadHolidays: @Sendable (HolidaySource) async -> [Holiday]
    @ObservationIgnored let clock: @Sendable () -> Date
    @ObservationIgnored let calendar: @Sendable () -> Calendar
    @ObservationIgnored public var didChange: (@MainActor () async -> Void)?

    public init(
        store: CalendarStore,
        sleepStore: SleepStore,
        storage: FlexTimeStorage = FlexTimeStorage(),
        workWeekStorage: WorkWeekStorage = WorkWeekStorage(),
        holidaySource: @escaping @Sendable () -> HolidaySource? = { DayHighlightSettings.highlightedHolidaySource() },
        loadHolidays: @escaping @Sendable (HolidaySource) async -> [Holiday] = {
            await HolidayRepository().holidays(for: $0)
        },
        clock: @escaping @Sendable () -> Date = { .now },
        calendar: @escaping @Sendable () -> Calendar = { .current }
    ) {
        self.store = store
        self.sleepStore = sleepStore
        self.storage = storage
        self.workWeekStorage = workWeekStorage
        self.holidaySource = holidaySource
        self.loadHolidays = loadHolidays
        self.clock = clock
        self.calendar = calendar
        enabledDayKinds = storage.enabledDayKinds
    }

    public func isEnabled(on kind: FlexTimeDayKind) -> Bool {
        enabledDayKinds.contains(kind)
    }

    public func setEnabled(_ isEnabled: Bool, on kind: FlexTimeDayKind) {
        storage.setEnabled(isEnabled, on: kind)
        enabledDayKinds = storage.enabledDayKinds
    }

    public var todayDelay: TimeInterval {
        _ = revision
        return storage.delay(on: HolidayDay(date: clock(), timeZone: calendar().timeZone))
    }

    /// Asks once a day, the first time the app is opened on a day that needs its events delayed.
    public func appDidBecomeActive() async {
        let now = clock()
        let today = HolidayDay(date: now, timeZone: calendar().timeZone)
        storage.recordOpen(at: now, on: today)
        guard prompt == nil, storage.promptedDay != today, storage.delay(on: today) == 0,
              store.eventAuthorization.allowsReading, !enabledDayKinds.isEmpty,
              await !dayKinds(of: now).isDisjoint(with: enabledDayKinds),
              let proposal = await proposal(at: now, requiresNeed: true),
              prompt == nil else { return }
        storage.promptedDay = today
        prompt = FlexTimePrompt(day: proposal.day, proposal: proposal)
    }

    public func presentForToday() async {
        let now = clock()
        prompt = FlexTimePrompt(
            day: calendar().startOfDay(for: now),
            proposal: await proposal(at: now, requiresNeed: false)
        )
    }

    public func dismissPrompt() {
        prompt = nil
    }

    public func delay(
        _ proposal: FlexTimeProposal,
        startingFirstEventAt start: Date,
        excluding excludedCalendars: Set<String> = []
    ) async {
        await setDelay(
            proposal.delay(startingFirstEventAt: start, excluding: excludedCalendars),
            excluding: excludedCalendars,
            onDayOf: proposal.day
        )
    }

    public func turnOff(onDayOf date: Date? = nil) async {
        await setDelay(0, excluding: [], onDayOf: date ?? clock())
    }

    private func setDelay(
        _ delay: TimeInterval,
        excluding excludedCalendars: Set<String>,
        onDayOf date: Date
    ) async {
        prompt = nil
        let day = HolidayDay(date: date, timeZone: calendar().timeZone)
        let excluded = delay > 0 ? excludedCalendars : []
        guard storage.delay(on: day) != delay || storage.excludedCalendars(on: day) != excluded else { return }
        storage.setDelay(delay, excluding: excluded, on: day)
        revision += 1
        store.flexTimeDidChange()
        await didChange?()
    }
}
