import Foundation
import Testing
@testable import Planner

struct EventMenuTests {
    private let start = Fixtures.date(2026, 10, 29, hour: 9)

    @Test func writableEventShowsEveryEditingAction() {
        let sections = EventMenu.sections(for: event(), context: context())
        #expect(sections == [
            [.showDetails],
            [.edit, .duplicate, .moveToCalendar([calendar("work")]), .copy],
            [.createLinkedNote],
            [.delete]
        ])
    }

    @Test func showDetailsComesFirst() {
        let items = EventMenu.items(for: event(location: "1 Infinite Loop"), context: context())
        #expect(items.first == .showDetails)
    }

    @Test func readOnlyEventOnlyShowsActionsThatMakeSense() {
        let holidays = calendar("holidays", isReadOnly: true)
        let readOnly = event(calendarIdentifier: "holidays", isReadOnly: true)
        let items = EventMenu.items(for: readOnly, context: context(eventCalendar: holidays))
        #expect(items == [.showDetails, .duplicate, .copy, .createLinkedNote])
    }

    @Test func noWritableCalendarsHidesDuplicate() {
        let holidays = calendar("holidays", isReadOnly: true)
        let readOnly = event(calendarIdentifier: "holidays", isReadOnly: true)
        let items = EventMenu.items(
            for: readOnly,
            context: EventMenuContext(eventCalendar: holidays, writableCalendars: [], hasLinkedNote: false)
        )
        #expect(!items.contains(.duplicate))
    }

    @Test func meetingLinkAddsJoin() throws {
        let link = try #require(event(url: URL(string: "https://acme.zoom.us/j/81234567890")).meetingLink)
        let items = EventMenu.items(for: event(url: link.url), context: context())
        #expect(items.prefix(2) == [.showDetails, .joinMeeting(link)])
    }

    @Test func locationAddsDirections() {
        let items = EventMenu.items(for: event(location: "Shibuya Station"), context: context())
        #expect(items.contains { if case .getDirections = $0 { true } else { false } })
    }

    @Test func linkedNoteSwitchesToOpen() {
        let items = EventMenu.items(for: event(), context: context(hasLinkedNote: true))
        #expect(items.contains(.openLinkedNote))
        #expect(!items.contains(.createLinkedNote))
    }

    @Test func moveOnlyOffersOtherCalendarsOfTheSameAccount() {
        let otherAccount = calendar("icloud", source: "icloud")
        let readOnlySameAccount = calendar("subscribed", isReadOnly: true)
        let destinations = EventMenu.moveDestinations(
            for: event(),
            context: context(extraCalendars: [otherAccount, readOnlySameAccount].filter { !$0.isReadOnly })
        )
        #expect(destinations == [calendar("work")])
    }

    @Test func singleCalendarHasNoMoveMenu() {
        let home = calendar("home")
        let items = EventMenu.items(
            for: event(),
            context: EventMenuContext(eventCalendar: home, writableCalendars: [home], hasLinkedNote: false)
        )
        #expect(!items.contains { if case .moveToCalendar = $0 { true } else { false } })
    }

    @Test func countdownShowsWhenAvailable() {
        let items = EventMenu.items(for: event(), context: context(canStartCountdown: true))
        #expect(items.prefix(2) == [.showDetails, .startCountdown])
    }

    @Test func respondOnlyForInvitationsInWritableCalendars() {
        let invitation = event(isReadOnly: true, hasAttendees: true)
        let items = EventMenu.items(for: invitation, context: context(canRespondToInvitations: true))
        #expect(items.contains(.respond))
        #expect(!items.contains(.edit))
        #expect(!items.contains(.delete))
        let organized = EventMenu.items(for: event(hasAttendees: true), context: context(canRespondToInvitations: true))
        #expect(!organized.contains(.respond))
    }

    private func calendar(_ identifier: String, source: String = "local", isReadOnly: Bool = false) -> PlannerCalendar {
        PlannerCalendar(
            id: identifier, title: identifier, kind: .event, color: .gray, sourceIdentifier: source,
            sourceTitle: source, sourceType: .local, isReadOnly: isReadOnly
        )
    }

    private func context(
        eventCalendar: PlannerCalendar? = nil,
        extraCalendars: [PlannerCalendar] = [],
        hasLinkedNote: Bool = false,
        canStartCountdown: Bool = false,
        canRespondToInvitations: Bool = false
    ) -> EventMenuContext {
        EventMenuContext(
            eventCalendar: eventCalendar ?? calendar("home"),
            writableCalendars: [calendar("home"), calendar("work")] + extraCalendars,
            hasLinkedNote: hasLinkedNote,
            canStartCountdown: canStartCountdown,
            canRespondToInvitations: canRespondToInvitations
        )
    }

    private func event(
        calendarIdentifier: String = "home",
        location: String? = nil,
        url: URL? = nil,
        isReadOnly: Bool = false,
        hasAttendees: Bool = false
    ) -> CalendarEvent {
        CalendarEvent(
            reference: Fixtures.reference(calendarIdentifier: calendarIdentifier),
            calendarIdentifier: calendarIdentifier,
            title: "Standup",
            location: location,
            url: url,
            startDate: start,
            endDate: start.addingTimeInterval(1800),
            hasAttendees: hasAttendees,
            isReadOnly: isReadOnly
        )
    }
}
