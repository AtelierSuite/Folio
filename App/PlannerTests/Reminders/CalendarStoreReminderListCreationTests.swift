import Foundation
import Testing
@testable import Planner

@MainActor
struct CalendarStoreReminderListCreationTests {
    private let sharedList = PlannerCalendar(
        id: "shared",
        title: "Shared",
        kind: .reminder,
        color: .gray,
        sourceIdentifier: "subscribed",
        sourceTitle: "Subscribed",
        sourceType: .subscription,
        isReadOnly: true
    )

    private func makeStore(source: FakeCalendarDataSource) throws -> CalendarStore {
        let defaults = try #require(UserDefaults(suiteName: "ReminderListCreationTests.\(UUID().uuidString)"))
        return CalendarStore(
            source: source,
            visibilityStorage: CalendarVisibilityStorage(defaults: defaults),
            reminderSettings: ReminderSettings(defaults: defaults)
        )
    }

    private func makeSource() -> FakeCalendarDataSource {
        FakeCalendarDataSource(calendars: [
            sharedList,
            Fixtures.plannerCalendar("list-1", kind: .reminder),
            Fixtures.plannerCalendar("list-2", kind: .reminder)
        ])
    }

    @Test func offersOnlyAccountsWithWritableLists() throws {
        let store = try makeStore(source: makeSource())
        #expect(store.reminderListAccounts == [ReminderListAccount(id: "source", title: "On My iPhone")])
        #expect(store.defaultReminderListAccountIdentifier == "source")
    }

    @Test func createdListAppearsWithTrimmedTitle() async throws {
        let store = try makeStore(source: makeSource())
        let color = ReminderListPalette.colors[2]
        let draft = ReminderListDraft(title: "  Groceries ", color: color, accountIdentifier: "source")
        let list = try await store.createReminderList(draft)
        #expect(list.title == "Groceries")
        #expect(list.color == color)
        #expect(store.reminderLists.contains(list))
    }

    @Test func rejectsBlankTitlesAndReadOnlyAccounts() async throws {
        let store = try makeStore(source: makeSource())
        await #expect(throws: ReminderEditingError.invalidDraft) {
            try await store.createReminderList(ReminderListDraft(title: "  ", accountIdentifier: "source"))
        }
        await #expect(throws: ReminderEditingError.accountNotFound) {
            try await store.createReminderList(ReminderListDraft(title: "Errands", accountIdentifier: "subscribed"))
        }
    }
}
