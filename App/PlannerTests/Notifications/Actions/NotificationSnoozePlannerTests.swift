import Foundation
import Testing
@testable import Planner

struct NotificationSnoozePlannerTests {
    private func snooze(_ name: String, minutes: Double) -> NotificationSnooze {
        NotificationSnooze(
            identifier: "folio.snooze.\(name)",
            fireDate: NotificationFixtures.now.addingTimeInterval(minutes * 60)
        )
    }

    @Test func snoozesWithinTheReservedSlotsAreKept() {
        let planner = NotificationSnoozePlanner(limit: 4)
        let pending = [snooze("a", minutes: 5), snooze("b", minutes: 10), snooze("c", minutes: 15)]
        #expect(planner.identifiersToRemove(pending: pending, adding: snooze("d", minutes: 5)).isEmpty)
    }

    @Test func snoozingTheSameItemAgainReplacesIt() {
        let planner = NotificationSnoozePlanner(limit: 1)
        let pending = [snooze("a", minutes: 5)]
        #expect(planner.identifiersToRemove(pending: pending, adding: snooze("a", minutes: 15)).isEmpty)
    }

    @Test func tooManySnoozesDropTheOnesDueSoonest() {
        let planner = NotificationSnoozePlanner(limit: 2)
        let pending = [snooze("late", minutes: 15), snooze("soon", minutes: 1), snooze("middle", minutes: 5)]
        let removed = planner.identifiersToRemove(pending: pending, adding: snooze("new", minutes: 5))
        #expect(removed == ["folio.snooze.soon", "folio.snooze.middle"])
    }

    @Test func defaultLimitIsTheSchedulersReservedSlots() {
        #expect(NotificationSnoozePlanner().limit == NotificationPlanner.defaultReservedSlots)
    }
}
