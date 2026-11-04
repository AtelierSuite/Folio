import Foundation
import Testing
@testable import Planner

struct EventDuplicateDetectorTests {
    private let detector = EventDuplicateDetector(calendar: Fixtures.calendar)
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

    @Test func differentDurationsAreDifferentEvents() {
        let groups = detector.groups(in: [event("first"), event("second", hours: 2)])
        #expect(groups.map(\.count) == [1, 1])
    }

    @Test func conflictingLocationsAreDifferentEvents() {
        let groups = detector.groups(in: [
            event("first", location: "Tokyo Office"),
            event("second", location: "Osaka Office")
        ])
        #expect(groups.map(\.count) == [1, 1])
    }

    @Test func aMoreDetailedLocationIsTheSamePlace() {
        let groups = detector.groups(in: [
            event("first", location: "Room 4"),
            event("second", location: "room 4, Tokyo Office"),
            event("third")
        ])
        #expect(groups.map(\.count) == [3])
    }

    @Test func sharedInvitationIdentifierMatchesDespiteARename() {
        let groups = detector.groups(in: [
            event("first", title: "Planning", external: "shared"),
            event("second", title: "Q4 planning (mine)", hours: 2, external: "shared")
        ])
        #expect(groups.map(\.count) == [2])
    }

    @Test func sharedMeetingLinkMatchesDespiteDifferentTitles() {
        let notes = "https://zoom.us/j/123456789"
        let groups = detector.groups(in: [
            event("first", title: "Design review", notes: notes),
            event("second", title: "Weekly catch-up", notes: notes)
        ])
        #expect(groups.map(\.count) == [2])
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

    @Test func anEventMatchingTwoGroupsMergesThem() {
        let groups = detector.groups(in: [
            event("first", title: "Planning", external: "invite"),
            event("second", title: "Roadmap"),
            event("third", title: "Roadmap", external: "invite")
        ])
        #expect(groups.map(\.count) == [3])
    }

    @Test func primaryIsTheEditableCopyThenTheMostDetailed() {
        let readOnly = event("first", location: "Room 4", notes: "Agenda", isReadOnly: true)
        let sparse = event("second")
        let detailed = event("third", location: "Room 4")
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
