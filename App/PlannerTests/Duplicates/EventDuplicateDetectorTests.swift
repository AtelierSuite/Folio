import Foundation
import Testing
@testable import Planner

struct EventDuplicateDetectorTests {
    private let detector: EventDuplicateDetector = {
        var detector = EventDuplicateDetector(calendar: Fixtures.calendar)
        detector.excludedCalendarIdentifiers = []
        return detector
    }()
    private let start = Fixtures.date(2026, 11, 4, hour: 9)

    private func event(
        _ local: String,
        title: String = "Team Sync",
        start: Date? = nil,
        hours: Double = 1,
        external: String? = nil,
        calendarIdentifier: String = "work",
        location: String? = nil,
        notes: String? = nil,
        isAllDay: Bool = false,
        isReadOnly: Bool = false
    ) -> CalendarEvent {
        let startDate = start ?? self.start
        return CalendarEvent(
            reference: Fixtures.reference(
                external: external ?? "external-\(local)",
                local: local,
                calendarIdentifier: calendarIdentifier,
                title: title,
                start: startDate
            ),
            calendarIdentifier: calendarIdentifier,
            title: title,
            location: location,
            notes: notes,
            startDate: startDate,
            endDate: startDate.addingTimeInterval(hours * 3600),
            isAllDay: isAllDay,
            isReadOnly: isReadOnly
        )
    }

    @Test func leavesDistinctEventsAlone() {
        let groups = detector.groups(in: [
            event("first", title: "Standup"),
            event("second", title: "Review"),
            event("third", title: "Standup", start: start.addingTimeInterval(3600))
        ])
        #expect(groups.map(\.count) == [1, 1, 1])
    }

    @Test(arguments: [
        ("Team Sync", "team sync"),
        ("Team Sync", "  Team   Sync "),
        ("Team - Sync", "Sync: Team"),
        ("Team Sync", "🎉 Team Sync"),
        ("Team Sync", "Fwd: RE: Team Sync"),
        ("Ｔｅａｍ Sync", "Team Sync")
    ])
    func matchesTitlesThatDifferOnlyInForm(first: String, second: String) {
        let groups = detector.groups(in: [
            event("first", title: first, calendarIdentifier: "work"),
            event("second", title: second, calendarIdentifier: "home")
        ])
        #expect(groups.map(\.count) == [2])
    }

    @Test func keepsJapaneseWordsThatDifferByDakutenApart() {
        let groups = detector.groups(in: [event("first", title: "かく"), event("second", title: "がく")])
        #expect(groups.map(\.count) == [1, 1])
    }

    @Test func untitledEventsAreNotDuplicatesOfEachOther() {
        let groups = detector.groups(in: [event("first", title: ""), event("second", title: " ")])
        #expect(groups.map(\.count) == [1, 1])
    }

    @Test func conflictingLocationsAreDifferentEvents() {
        let groups = detector.groups(in: [
            event("first", location: "Tokyo Office"),
            event("second", location: "Osaka Office")
        ])
        #expect(groups.map(\.count) == [1, 1])
    }

    private func offset(_ minutes: Double) -> Date {
        start.addingTimeInterval(minutes * 60)
    }

    @Test func startsAndEndsWithinThirtyMinutesMatch() {
        let groups = detector.groups(in: [
            event("first"),
            event("second", start: offset(30), hours: 1)
        ])
        #expect(groups.map(\.count) == [2])
    }

    @Test func startsMoreThanThirtyMinutesApartAreDifferentEvents() {
        let groups = detector.groups(in: [event("first"), event("second", start: offset(31))])
        #expect(groups.map(\.count) == [1, 1])
    }

    @Test func endsMoreThanThirtyMinutesApartAreDifferentEvents() {
        let groups = detector.groups(in: [event("first"), event("second", hours: 1.6)])
        #expect(groups.map(\.count) == [1, 1])
    }

    @Test func groupsNeverSpanMoreThanTheTolerance() {
        let groups = detector.groups(in: [
            event("first"),
            event("second", start: offset(20)),
            event("third", start: offset(40))
        ])
        #expect(groups.map(\.count).sorted() == [1, 2])
    }

    @Test func titlesWithinFivePercentMatch() {
        let groups = detector.groups(in: [
            event("first", title: "Quarterly planning with the finance team"),
            event("second", title: "Quarterly planing with the finance team")
        ])
        #expect(groups.map(\.count) == [2])
    }

    @Test func titlesMoreThanFivePercentApartAreDifferentEvents() {
        let groups = detector.groups(in: [event("first", title: "Team Sync"), event("second", title: "Team Sink")])
        #expect(groups.map(\.count) == [1, 1])
    }

    @Test func locationsThatDifferOnlyInFormMatch() {
        let groups = detector.groups(in: [
            event("first", location: "Room 4, Tokyo Office"),
            event("second", location: "room 4 tokyo office")
        ])
        #expect(groups.map(\.count) == [2])
    }

    @Test func aLocationOnOnlyOneEventIsADifference() {
        let groups = detector.groups(in: [event("first", location: "Room 4"), event("second")])
        #expect(groups.map(\.count) == [1, 1])
    }

    @Test func excludedCalendarsAreNeverGrouped() {
        var detector = detector
        detector.excludedCalendarIdentifiers = ["home"]
        let groups = detector.groups(in: [
            event("first", calendarIdentifier: "work"),
            event("second", calendarIdentifier: "home"),
            event("third", calendarIdentifier: "school")
        ])
        #expect(groups.map(\.count) == [2, 1])
    }

    @Test func allDayEventsMatchWhicheverWayTheyMarkTheirEnd() {
        let midnight = Fixtures.date(2026, 11, 4)
        let groups = detector.groups(in: [
            event("first", title: "Holiday", start: midnight, hours: 24, isAllDay: true),
            event("second", title: "holiday", start: midnight, hours: 24 - 1.0 / 3600, isAllDay: true)
        ])
        #expect(groups.map(\.count) == [2])
    }

    @Test func allDayAndTimedEventsNeverMatch() {
        let midnight = Fixtures.date(2026, 11, 4)
        let groups = detector.groups(in: [
            event("first", start: midnight, hours: 24, isAllDay: true),
            event("second", start: midnight, hours: 24)
        ])
        #expect(groups.map(\.count) == [1, 1])
    }

    @Test func primaryIsTheEditableCopyThenTheMostDetailed() {
        let readOnly = event("first", location: "Room 4", notes: "Agenda", isReadOnly: true)
        let sparse = event("second", location: "Room 4")
        let detailed = event("third", location: "Room 4", notes: "Agenda")
        let group = detector.groups(in: [readOnly, sparse, detailed])[0]
        #expect(group.primary == detailed)
        #expect(group.duplicates == [sparse, readOnly])
    }

    @Test func primaryDoesNotDependOnInputOrder() {
        let first = event("first")
        let second = event("second")
        let forwards = detector.groups(in: [first, second])[0]
        let backwards = detector.groups(in: [second, first])[0]
        #expect(forwards.primary == backwards.primary)
    }

    @Test func groupsKeepTheOrderOfTheirEarliestEvent() {
        let later = start.addingTimeInterval(3600)
        let groups = detector.groups(in: [
            event("first", title: "Later", start: later),
            event("second", title: "Earlier"),
            event("third", title: "Later", start: later)
        ])
        #expect(groups.map(\.primary.title) == ["Later", "Earlier"])
    }
}
