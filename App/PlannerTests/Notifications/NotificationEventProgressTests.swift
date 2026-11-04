import Foundation
import Testing
@testable import Planner

struct NotificationEventProgressTests {
    private let start = Fixtures.date(2026, 10, 29, hour: 9)
    private let locale = Locale(identifier: "en_GB")

    private var progress: NotificationEventProgress {
        NotificationEventProgress(start: start, end: start.addingTimeInterval(3600))
    }

    private func text(minutesFromStart minutes: Double) -> String {
        progress.text(at: start.addingTimeInterval(minutes * 60), locale: locale)
    }

    @Test func beforeTheStartCountsDown() {
        #expect(text(minutesFromStart: -10) == "In 10 minutes")
    }

    @Test func partOfAMinuteLeftRoundsUp() {
        #expect(text(minutesFromStart: -9.5) == "In 10 minutes")
    }

    @Test func aroundTheStartSaysItIsStarting() {
        #expect(text(minutesFromStart: -0.5) == NotificationEventProgress.startingNowText)
        #expect(text(minutesFromStart: 0) == NotificationEventProgress.startingNowText)
        #expect(text(minutesFromStart: 0.5) == NotificationEventProgress.startingNowText)
    }

    @Test func afterTheStartCountsUp() {
        #expect(text(minutesFromStart: 10).contains("10 minutes ago"))
    }

    @Test func atTheEndSaysItEnded() {
        #expect(text(minutesFromStart: 60) == NotificationEventProgress.endedText)
        #expect(text(minutesFromStart: 600) == NotificationEventProgress.endedText)
    }

    @Test func eventWithNoLengthNeverEnds() {
        let instant = NotificationEventProgress(start: start, end: start)
        #expect(instant.text(at: start.addingTimeInterval(600), locale: locale).contains("10 minutes ago"))
    }
}
