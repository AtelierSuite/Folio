import Foundation

extension FlexTimeCenter {
    func proposal(at now: Date, requiresNeed: Bool) async -> FlexTimeProposal? {
        let calendar = calendar()
        let advisor = FlexTimeAdvisor(calendar: calendar)
        let today = HolidayDay(date: now, timeZone: calendar.timeZone)
        let events = await store.scheduledEvents(in: advisor.dayInterval(containing: now))
        return advisor.proposal(
            events: events,
            wake: await wake(at: now, advisor: advisor),
            now: now,
            activeDelay: storage.delay(on: today),
            activeExcludedCalendars: storage.excludedCalendars(on: today),
            requiresNeed: requiresNeed
        )
    }

    func dayKinds(of date: Date) async -> Set<FlexTimeDayKind> {
        var holidays: Set<HolidayDay> = []
        if enabledDayKinds.contains(.publicHoliday), let source = holidaySource() {
            holidays = Set(await loadHolidays(source).map(\.day))
        }
        let calendar = calendar()
        return FlexTimeDayClassifier(
            workdays: workWeekStorage.resolvedWorkdays(calendar: calendar),
            holidays: holidays
        ).kinds(of: date, calendar: calendar)
    }

    /// Sleep that ended today when it is tracked, otherwise the first time the app was opened today.
    private func wake(at now: Date, advisor: FlexTimeAdvisor) async -> FlexTimeWake? {
        let calendar = advisor.calendar
        if sleepStore.informsFlexTime {
            let sessions = await sleepStore.sessions(in: SleepWindow.lastNight(now: now, calendar: calendar))
            if let wakeTime = advisor.wakeTime(from: sessions, on: now) {
                return FlexTimeWake(time: wakeTime, source: .sleep)
            }
        }
        return storage.firstOpen(on: HolidayDay(date: now, timeZone: calendar.timeZone))
            .map { FlexTimeWake(time: $0, source: .firstOpen) }
    }
}
