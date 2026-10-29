import Foundation
import Testing
@testable import Planner

struct EventDraftTests {
    private let calendar = Fixtures.calendar

    @Test func newEventOnTodayStartsAtTheNextHour() {
        let now = Fixtures.date(2026, 10, 29, hour: 14).addingTimeInterval(20 * 60)
        let draft = EventDraft.newEvent(
            on: Fixtures.date(2026, 10, 29), calendarIdentifier: "work", now: now, calendar: calendar
        )
        #expect(draft.startDate == Fixtures.date(2026, 10, 29, hour: 15))
        #expect(draft.endDate == Fixtures.date(2026, 10, 29, hour: 16))
        #expect(draft.timeZone == calendar.timeZone)
        #expect(draft.calendarIdentifier == "work")
    }

    @Test func newEventOnAnotherDayStartsAtNine() {
        let draft = EventDraft.newEvent(
            on: Fixtures.date(2026, 11, 2), calendarIdentifier: "work",
            now: Fixtures.date(2026, 10, 29, hour: 14), calendar: calendar
        )
        #expect(draft.startDate == Fixtures.date(2026, 11, 2, hour: 9))
    }

    @Test func newEventLateAtNightFallsBackToNine() {
        let now = Fixtures.date(2026, 10, 29, hour: 23).addingTimeInterval(30 * 60)
        let draft = EventDraft.newEvent(
            on: Fixtures.date(2026, 10, 29), calendarIdentifier: "work", now: now, calendar: calendar
        )
        #expect(draft.startDate == Fixtures.date(2026, 10, 29, hour: 9))
    }

    @Test func togglingAllDayCoversWholeDaysAndFloats() {
        var draft = EventDraft(
            calendarIdentifier: "work",
            startDate: Fixtures.date(2026, 10, 29, hour: 10),
            endDate: Fixtures.date(2026, 10, 30, hour: 11),
            alerts: [.minutesBefore(15)]
        )
        draft.setAllDay(true, calendar: calendar)
        #expect(draft.startDate == Fixtures.date(2026, 10, 29))
        #expect(draft.endDate == Fixtures.date(2026, 10, 31))
        #expect(draft.timeZone == nil)
        #expect(draft.savedTimeZone == nil)
        #expect(draft.alerts == [EventAlert.defaultAlert(isAllDay: true)])

        draft.setAllDay(false, calendar: calendar)
        #expect(draft.duration == EventDraft.defaultDuration)
        #expect(draft.timeZone == calendar.timeZone)
        #expect(draft.alerts == [EventAlert.defaultAlert(isAllDay: false)])
    }

    @Test func movingStartKeepsDuration() {
        var draft = EventDraft(
            calendarIdentifier: "work",
            startDate: Fixtures.date(2026, 10, 29, hour: 10),
            endDate: Fixtures.date(2026, 10, 29, hour: 12)
        )
        draft.moveStart(to: Fixtures.date(2026, 10, 30, hour: 8))
        #expect(draft.endDate == Fixtures.date(2026, 10, 30, hour: 10))
        #expect(draft.hasValidDates)
    }

    @Test func seriesEditKeepsTimeShiftAndNewDuration() {
        let draft = EventDraft(
            title: "Standup",
            calendarIdentifier: "work",
            startDate: Fixtures.date(2026, 10, 29, hour: 10),
            endDate: Fixtures.date(2026, 10, 29, hour: 12)
        )
        let seriesDraft = draft.appliedToSeries(
            editedOccurrenceStart: Fixtures.date(2026, 10, 29, hour: 9),
            firstOccurrenceStart: Fixtures.date(2026, 10, 1, hour: 9),
            calendar: calendar
        )
        #expect(seriesDraft.startDate == Fixtures.date(2026, 10, 1, hour: 10))
        #expect(seriesDraft.endDate == Fixtures.date(2026, 10, 1, hour: 12))
        #expect(seriesDraft.title == "Standup")
    }

    @Test func seriesEditKeepsWallClockAcrossDaylightSaving() throws {
        var berlin = Calendar(identifier: .gregorian)
        berlin.timeZone = try #require(TimeZone(identifier: "Europe/Berlin"))
        let firstStart = try #require(berlin.date(from: DateComponents(year: 2026, month: 10, day: 24, hour: 9)))
        let editedStart = try #require(berlin.date(from: DateComponents(year: 2026, month: 11, day: 5, hour: 9)))
        let movedStart = try #require(berlin.date(byAdding: .day, value: 2, to: editedStart))
        let draft = EventDraft(
            calendarIdentifier: "work", startDate: movedStart, endDate: movedStart.addingTimeInterval(3600)
        )
        let seriesDraft = draft.appliedToSeries(
            editedOccurrenceStart: editedStart, firstOccurrenceStart: firstStart, calendar: berlin
        )
        let expectedStart = try #require(berlin.date(from: DateComponents(year: 2026, month: 10, day: 26, hour: 9)))
        #expect(seriesDraft.startDate == expectedStart)
        #expect(seriesDraft.duration == 3600)
    }

    @Test func locationTextRoundTrips() {
        let location = EventLocation(
            title: "Apple Park",
            address: "One Apple Park Way, Cupertino",
            coordinate: EventCoordinate(latitude: 37.33, longitude: -122.01)
        )
        #expect(location.text == "Apple Park\nOne Apple Park Way, Cupertino")
        let parsed = EventLocation(text: location.text, coordinate: location.coordinate)
        #expect(parsed == location)
        #expect(EventLocation(text: "  ") == nil)
        #expect(EventLocation(text: "Office")?.address == nil)
    }

    @Test func urlTextGetsAScheme() {
        #expect(EventDraft.url(fromText: " folio.app ")?.absoluteString == "https://folio.app")
        #expect(EventDraft.url(fromText: "mailto:hello@folio.app")?.scheme == "mailto")
        #expect(EventDraft.url(fromText: "") == nil)
        #expect(EventDraft.url(fromText: "not a url") == nil)
    }

    @Test func recurrenceIntervalIsAtLeastOne() {
        #expect(EventRecurrence(frequency: .weekly, interval: 0).interval == 1)
    }
}
