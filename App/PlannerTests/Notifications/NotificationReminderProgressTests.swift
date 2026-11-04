import Foundation
import Testing
@testable import Planner

struct NotificationReminderProgressTests {
    private let due = Fixtures.date(2026, 10, 29, hour: 9)
    private let locale = Locale(identifier: "en_GB")
    private let calendar = Fixtures.calendar

    private func timed(minutesFromDue minutes: Double) -> String {
        NotificationReminderProgress(dueDate: due, hasDueTime: true)
            .text(at: due.addingTimeInterval(minutes * 60), locale: locale, calendar: calendar)
    }

    private func dateOnly(daysFromDue days: Double) -> String {
        NotificationReminderProgress(dueDate: due, hasDueTime: false)
            .text(at: due.addingTimeInterval(days * 86_400), locale: locale, calendar: calendar)
    }

    @Test func beforeTheDueTimeCountsDown() {
        #expect(timed(minutesFromDue: -10).contains("in 10 minutes"))
        #expect(timed(minutesFromDue: -9.5).contains("in 10 minutes"))
    }

    @Test func aroundTheDueTimeSaysItIsDue() {
        #expect(timed(minutesFromDue: -0.5) == NotificationReminderProgress.dueNowText)
        #expect(timed(minutesFromDue: 0.5) == NotificationReminderProgress.dueNowText)
    }

    @Test func afterTheDueTimeSaysHowLate() {
        #expect(timed(minutesFromDue: 1.5).contains("1 minute"))
        #expect(timed(minutesFromDue: 120).contains("2 hours"))
        #expect(timed(minutesFromDue: 2880).contains("2 days"))
    }

    @Test func overdueStartsAfterTheDueMinute() {
        let progress = NotificationReminderProgress(dueDate: due, hasDueTime: true)
        #expect(!progress.isOverdue(at: due.addingTimeInterval(30), calendar: calendar))
        #expect(progress.isOverdue(at: due.addingTimeInterval(60), calendar: calendar))
    }

    @Test func dateOnlyReminderCountsInDays() {
        #expect(dateOnly(daysFromDue: 0) == NotificationReminderProgress.dueTodayText)
        #expect(dateOnly(daysFromDue: -1).contains("tomorrow"))
        #expect(dateOnly(daysFromDue: -3).contains("in 3 days"))
        #expect(dateOnly(daysFromDue: 2).contains("2 days"))
    }

    @Test func dateOnlyReminderIsNotOverdueOnItsDay() {
        let progress = NotificationReminderProgress(dueDate: due, hasDueTime: false)
        #expect(!progress.isOverdue(at: due.addingTimeInterval(3600 * 10), calendar: calendar))
        #expect(progress.isOverdue(at: due.addingTimeInterval(86_400), calendar: calendar))
    }
}
