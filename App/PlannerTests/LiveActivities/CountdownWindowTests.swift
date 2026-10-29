import Foundation
import Testing
@testable import Planner

struct CountdownWindowTests {
    private let window = CountdownWindow()
    private let start = Fixtures.date(2026, 10, 29, hour: 18)

    private func hoursBeforeStart(_ hours: Double) -> Date {
        start.addingTimeInterval(-hours * 3600)
    }

    @Test func opensEightHoursBeforeStart() {
        let event = Fixtures.countdownEvent(local: "dinner", start: start)
        #expect(window.availability(for: event, at: hoursBeforeStart(8.5)) == .notYet(availableFrom: hoursBeforeStart(8)))
        #expect(window.availability(for: event, at: hoursBeforeStart(8)).state != nil)
        #expect(window.availability(for: event, at: hoursBeforeStart(1)).state != nil)
    }

    @Test func countsToEndWhenTheEndFitsInTheWindow() {
        let event = Fixtures.countdownEvent(local: "dinner", start: start, hours: 2)
        #expect(window.availability(for: event, at: hoursBeforeStart(6)).state?.endDate == event.endDate)
        #expect(window.availability(for: event, at: hoursBeforeStart(7)).state?.endDate == nil)
        #expect(window.availability(for: event, at: hoursBeforeStart(7)).state?.finishDate == start)
    }

    @Test func inProgressEventCountsToItsEnd() {
        let event = Fixtures.countdownEvent(local: "workshop", start: start, hours: 3)
        let state = window.availability(for: event, at: start.addingTimeInterval(3600)).state
        #expect(state?.endDate == event.endDate)
    }

    @Test func inProgressEventEndingBeyondTheWindowIsUnavailable() {
        let event = Fixtures.countdownEvent(local: "conference", start: start, hours: 10)
        #expect(window.availability(for: event, at: start.addingTimeInterval(60)) == .unavailable)
    }

    @Test func endedAndAllDayEventsAreUnavailable() {
        let event = Fixtures.countdownEvent(local: "dinner", start: start)
        #expect(window.availability(for: event, at: event.endDate) == .unavailable)
        let allDay = CalendarEvent(
            reference: Fixtures.reference(), calendarIdentifier: "calendar-1", title: "Holiday",
            startDate: start, endDate: start.addingTimeInterval(86400), isAllDay: true
        )
        #expect(window.availability(for: allDay, at: hoursBeforeStart(1)) == .unavailable)
    }

    @Test func zeroLengthEventCountsUntilItStarts() {
        let event = Fixtures.countdownEvent(local: "deadline", start: start, hours: 0)
        #expect(window.availability(for: event, at: hoursBeforeStart(1)).state?.finishDate == start)
        #expect(window.availability(for: event, at: start) == .unavailable)
    }

    @Test func runningCountdownKeepsItsOriginalDeadline() {
        let event = Fixtures.countdownEvent(local: "dinner", start: start, hours: 2)
        let startedAt = hoursBeforeStart(7)
        #expect(window.state(for: event, startedAt: startedAt, now: hoursBeforeStart(1))?.endDate == nil)
        #expect(window.state(for: event, startedAt: startedAt, now: start) == nil)
    }

    @Test func eventMovedOutOfTheWindowEndsTheCountdown() {
        let moved = Fixtures.countdownEvent(local: "dinner", start: start.addingTimeInterval(3 * 3600))
        #expect(window.state(for: moved, startedAt: hoursBeforeStart(6), now: hoursBeforeStart(5)) == nil)
    }

    @Test func nextEventSkipsStartedAndFarEvents() {
        let now = hoursBeforeStart(2)
        let events = [
            Fixtures.countdownEvent(local: "running", start: now.addingTimeInterval(-600)),
            Fixtures.countdownEvent(local: "later", start: start.addingTimeInterval(3600)),
            Fixtures.countdownEvent(local: "soon", start: start),
            Fixtures.countdownEvent(local: "tomorrow", start: start.addingTimeInterval(86400))
        ]
        #expect(window.nextEvent(in: events, at: now)?.title == "soon")
    }
}
