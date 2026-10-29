import Foundation
import Testing
@testable import Planner

@MainActor
struct SystemTimeObserverTests {
    private final class CalendarBox: @unchecked Sendable {
        var calendar: Calendar

        init(_ identifier: String) {
            calendar = Self.calendar(identifier)
        }

        func use(_ identifier: String) {
            calendar = Self.calendar(identifier)
        }

        static func calendar(_ identifier: String) -> Calendar {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = TimeZone(identifier: identifier) ?? .gmt
            return calendar
        }
    }

    private func waitForChange(_ observer: SystemTimeObserver, count: Int) async {
        for _ in 0..<200 where observer.changeCount < count {
            try? await Task.sleep(for: .milliseconds(5))
        }
    }

    @Test func startsWithTheCurrentCalendar() {
        let box = CalendarBox("Europe/London")
        let observer = SystemTimeObserver(notificationCenter: NotificationCenter()) { box.calendar }
        #expect(observer.timeZone.identifier == "Europe/London")
        #expect(observer.changeCount == 0)
    }

    @Test(arguments: SystemTimeObserver.changeNotifications)
    func systemChangesUpdateTheCalendarAndNotify(name: Notification.Name) async {
        let center = NotificationCenter()
        let box = CalendarBox("Europe/London")
        let observer = SystemTimeObserver(notificationCenter: center) { box.calendar }
        var handledCount = 0
        observer.startObserving { handledCount += 1 }
        box.use("Asia/Tokyo")
        center.post(name: name, object: nil)
        await waitForChange(observer, count: 1)
        #expect(observer.changeCount == 1)
        #expect(observer.timeZone.identifier == "Asia/Tokyo")
        #expect(handledCount == 1)
        observer.stopObserving()
    }

    @Test func onlyTheFirstStartRegistersAHandler() async {
        let center = NotificationCenter()
        let observer = SystemTimeObserver(notificationCenter: center) { CalendarBox.calendar("UTC") }
        var firstCount = 0
        var secondCount = 0
        observer.startObserving { firstCount += 1 }
        observer.startObserving { secondCount += 1 }
        center.post(name: .NSSystemTimeZoneDidChange, object: nil)
        await waitForChange(observer, count: 1)
        #expect(firstCount == 1)
        #expect(secondCount == 0)
        observer.stopObserving()
    }

    @Test func unrelatedNotificationsAreIgnored() async {
        let center = NotificationCenter()
        let observer = SystemTimeObserver(notificationCenter: center) { CalendarBox.calendar("UTC") }
        observer.startObserving()
        center.post(name: Notification.Name("Unrelated"), object: nil)
        try? await Task.sleep(for: .milliseconds(50))
        #expect(observer.changeCount == 0)
        observer.stopObserving()
    }

    @Test func stoppedObserverIgnoresChanges() async {
        let center = NotificationCenter()
        let observer = SystemTimeObserver(notificationCenter: center) { CalendarBox.calendar("UTC") }
        observer.startObserving()
        observer.stopObserving()
        center.post(name: .NSSystemTimeZoneDidChange, object: nil)
        try? await Task.sleep(for: .milliseconds(50))
        #expect(observer.changeCount == 0)
    }

    @Test func systemCalendarUsesTheCurrentTimeZone() {
        #expect(SystemTimeObserver.systemCalendar().timeZone == TimeZone.current)
    }
}
