import Foundation
import Testing
@testable import Planner

struct NotificationTriggerIntervalTests {
    private let fireDate = NotificationFixtures.now.addingTimeInterval(600)

    private var notification: PlannedNotification {
        PlannedNotification(NotificationCandidate(
            fireDate: fireDate, kind: .event, reference: Fixtures.reference(external: nil, local: "work"),
            content: NotificationContent(title: "work", body: "")
        ))
    }

    @Test func intervalCountsFromTheMomentTheAlertIsAdded() {
        let addedLater = NotificationFixtures.now.addingTimeInterval(5)
        #expect(notification.triggerInterval(from: addedLater) == 595)
    }

    @Test func pastFireDatesStillGiveAValidInterval() {
        #expect(notification.triggerInterval(from: fireDate) == 1)
        #expect(notification.triggerInterval(from: fireDate.addingTimeInterval(30)) == 1)
    }
}
