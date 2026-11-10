import Foundation
import Testing
@testable import Planner

@MainActor
struct DefaultCalendarTests {
    private let home = Fixtures.plannerCalendar("home")
    private let work = Fixtures.plannerCalendar("work")
    private let errands = Fixtures.plannerCalendar("errands", kind: .reminder)
    private let groceries = Fixtures.plannerCalendar("groceries", kind: .reminder)
    private let holidays = PlannerCalendar(
        id: "holidays", title: "Holidays", kind: .event, color: .gray,
        sourceIdentifier: "subscribed", sourceTitle: "Subscribed", sourceType: .subscription, isReadOnly: true
    )

    private func makeDefaults() throws -> UserDefaults {
        try #require(UserDefaults(suiteName: "DefaultCalendarTests.\(UUID().uuidString)"))
    }

    private func makeStore(defaults: UserDefaults, source: FakeCalendarDataSource? = nil) -> CalendarStore {
        CalendarStore(source: source ?? makeSource(), visibilityStorage: CalendarVisibilityStorage(defaults: defaults))
    }

    private func makeSource() -> FakeCalendarDataSource {
        let source = FakeCalendarDataSource(calendars: [home, work, holidays, errands, groceries])
        source.setDefaultEventCalendarIdentifier("home")
        return source
    }

    @Test func chosenDefaultsWinOverTheSystemDefaults() throws {
        let store = makeStore(defaults: try makeDefaults())
        #expect(store.defaultEventCalendarIdentifier == "home")
        #expect(store.defaultReminderListIdentifier == "errands")
        store.setDefault(work)
        store.setDefault(groceries)
        #expect(store.defaultEventCalendarIdentifier == "work")
        #expect(store.defaultReminderListIdentifier == "groceries")
        #expect(store.isDefault(work) && !store.isDefault(home))
        #expect(store.isDefault(groceries) && !store.isDefault(errands))
    }

    @Test func chosenDefaultsPersist() throws {
        let defaults = try makeDefaults()
        let source = makeSource()
        makeStore(defaults: defaults, source: source).setDefault(work)
        let reopened = makeStore(defaults: defaults, source: source)
        #expect(reopened.defaultEventCalendarIdentifier == "work")
    }

    @Test func readOnlyCalendarsCannotBecomeDefault() throws {
        let store = makeStore(defaults: try makeDefaults())
        store.setDefault(holidays)
        #expect(store.defaultEventCalendarIdentifier == "home")
    }

    @Test func missingChosenDefaultFallsBackToTheSystemDefault() throws {
        let defaults = try makeDefaults()
        CalendarVisibilityStorage(defaults: defaults).defaultEventCalendarIdentifier = "deleted"
        let store = makeStore(defaults: defaults)
        #expect(store.defaultEventCalendarIdentifier == "home")
    }
}
