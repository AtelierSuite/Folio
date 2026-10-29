import Foundation
import Testing
@testable import Planner

struct EventActionHelpersTests {
    private let start = Fixtures.date(2026, 10, 29, hour: 9)

    @Test func directionsPreferTheCoordinate() throws {
        let url = try #require(EventDirections.url(for: event(
            location: "Apple Park", coordinate: PlannerCoordinate(latitude: 37.3349, longitude: -122.009)
        )))
        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        #expect(url.host() == "maps.apple.com")
        #expect(items.contains(URLQueryItem(name: "daddr", value: "37.3349,-122.009")))
    }

    @Test func directionsFallBackToTheAddress() throws {
        let url = try #require(EventDirections.url(for: event(location: "1-1 Marunouchi, Tokyo")))
        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        #expect(items == [URLQueryItem(name: "daddr", value: "1-1 Marunouchi, Tokyo")])
    }

    @Test func noDirectionsWithoutAPlace() {
        #expect(EventDirections.url(for: event(location: nil)) == nil)
        #expect(EventDirections.url(for: event(location: "  ")) == nil)
        #expect(EventDirections.url(for: event(location: "https://acme.zoom.us/j/81234567890")) == nil)
    }

    @Test func tapOutcomeFollowsTheSetting() {
        #expect(EventTapBehavior.opensDetails.outcome(of: .tap, usesPointerSelection: false) == .showDetails)
        #expect(EventTapBehavior.showsQuickActions.outcome(of: .tap, usesPointerSelection: false) == .showMenu)
    }

    @Test func pointerClickSelectsAndDoubleClickOpens() {
        #expect(EventTapBehavior.opensDetails.outcome(of: .tap, usesPointerSelection: true) == .select)
        #expect(EventTapBehavior.opensDetails.outcome(of: .doubleTap, usesPointerSelection: true) == .showDetails)
        #expect(EventTapBehavior.showsQuickActions.outcome(of: .tap, usesPointerSelection: true) == .showMenu)
        #expect(EventTapBehavior.showsQuickActions.outcome(of: .doubleTap, usesPointerSelection: true) == .showDetails)
    }

    @Test func settingDefaultsToOpeningDetails() throws {
        let defaults = try #require(UserDefaults(suiteName: "EventTapSettingsTests.\(UUID().uuidString)"))
        let settings = EventTapSettings(defaults: defaults)
        #expect(settings.behavior == .opensDetails)
        settings.behavior = .showsQuickActions
        #expect(settings.behavior == .showsQuickActions)
    }

    @Test func copyTextListsTitleTimePlaceAndLink() {
        var calendar = Fixtures.calendar
        calendar.locale = Locale(identifier: "en_US")
        let text = EventCopyText.text(
            for: event(location: "Room 4", url: URL(string: "https://example.com/agenda")),
            calendar: calendar,
            locale: Locale(identifier: "en_US")
        )
        let lines = text.components(separatedBy: "\n")
        #expect(lines.count == 4)
        #expect(lines[0] == "Standup")
        #expect(lines[1].contains("Thursday"))
        #expect(lines[1].contains("9:00"))
        #expect(lines[2] == "Room 4")
        #expect(lines[3] == "https://example.com/agenda")
    }

    @Test func copyTextForAllDayHasNoTime() {
        let allDay = CalendarEvent(
            reference: Fixtures.reference(), calendarIdentifier: "home", title: "Holiday",
            startDate: Fixtures.date(2026, 11, 3), endDate: Fixtures.date(2026, 11, 4), isAllDay: true
        )
        let text = EventCopyText.text(for: allDay, calendar: Fixtures.calendar, locale: Locale(identifier: "en_US"))
        #expect(text == "Holiday\nTuesday, November 3, 2026")
    }

    @Test func duplicateDropsRecurrenceAndLeavesReadOnlyCalendars() {
        let draft = EventDraft(
            title: "Standup", calendarIdentifier: "holidays", startDate: start, endDate: start,
            recurrence: EventRecurrence(frequency: .daily)
        )
        let copy = draft.duplicated(writableCalendarIdentifiers: ["home"], fallbackCalendarIdentifier: "home")
        #expect(copy.recurrence == nil)
        #expect(copy.calendarIdentifier == "home")
        #expect(copy.title == "Standup")
        let writableCopy = draft.moved(toCalendar: "home")
            .duplicated(writableCalendarIdentifiers: ["home", "work"], fallbackCalendarIdentifier: "work")
        #expect(writableCopy.calendarIdentifier == "home")
    }

    private func event(location: String?, coordinate: PlannerCoordinate? = nil, url: URL? = nil) -> CalendarEvent {
        CalendarEvent(
            reference: Fixtures.reference(),
            calendarIdentifier: "home",
            title: "Standup",
            location: location,
            coordinate: coordinate,
            url: url,
            startDate: start,
            endDate: start.addingTimeInterval(1800),
            timeZone: Fixtures.calendar.timeZone
        )
    }
}
