import Foundation
import Testing
@testable import Planner

struct NotificationActionContextTests {
    @Test func meetingLinkComesFromTheEventURLFirst() throws {
        let url = try #require(NotificationActionFixtures.zoomURL)
        let event = NotificationActionFixtures.event(notes: "Backup https://meet.google.com/abc", url: url)
        #expect(NotificationActionContext(event: event).meetingURL == url)
    }

    @Test func meetingLinkIsFoundInNotesOrLocation() {
        let inNotes = NotificationActionFixtures.event(notes: "Dial in: https://meet.google.com/abc-defg-hij thanks")
        #expect(NotificationActionContext(event: inNotes).meetingURL?.absoluteString == "https://meet.google.com/abc-defg-hij")
        let inLocation = NotificationActionFixtures.event(location: "https://teams.microsoft.com/l/meetup")
        #expect(NotificationActionContext(event: inLocation).meetingURL?.host() == "teams.microsoft.com")
    }

    @Test func linkOnlyLocationIsNotAPlace() {
        let event = NotificationActionFixtures.event(location: "https://zoom.us/j/1")
        #expect(NotificationActionContext(event: event).place == nil)
    }

    @Test func addressOrCoordinateMakesAPlace() {
        let address = NotificationActionContext(event: NotificationActionFixtures.event(location: "  1 Infinite Loop  "))
        #expect(address.place?.name == "1 Infinite Loop")
        #expect(address.meetingURL == nil)
        let pinned = NotificationActionContext(
            event: NotificationActionFixtures.event(coordinate: NotificationActionFixtures.office)
        )
        #expect(pinned.place?.coordinate == NotificationActionFixtures.office)
        #expect(NotificationActionContext(event: NotificationActionFixtures.event(location: " ")).place == nil)
    }

    @Test func directionsUseCoordinatesWhenKnown() throws {
        let place = try #require(NotificationPlace(name: "Tokyo Station", coordinate: NotificationActionFixtures.office))
        let url = try #require(place.directionsURL)
        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        #expect(url.host() == "maps.apple.com")
        #expect(items.first { $0.name == "daddr" }?.value == "35.6812,139.7671")
        #expect(items.first { $0.name == "q" }?.value == "Tokyo Station")
    }

    @Test func directionsFallBackToTheAddress() throws {
        let place = try #require(NotificationPlace(name: "1 Infinite Loop, Cupertino", coordinate: nil))
        let items = try #require(place.directionsURL.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }?.queryItems)
        #expect(items == [URLQueryItem(name: "daddr", value: "1 Infinite Loop, Cupertino")])
    }

    @Test func plannedEventsGetTheirCategoryAndContext() throws {
        let event = NotificationActionFixtures.event(location: "Room 4", url: NotificationActionFixtures.zoomURL)
        let planned = try #require(NotificationActionFixtures.planned(event))
        #expect(planned.category == .eventWithMeetingAndPlace)
        #expect(planned.actionContext.meetingURL == NotificationActionFixtures.zoomURL)
    }

    @Test func addingALinkReschedulesTheAlert() throws {
        let plain = try #require(NotificationActionFixtures.planned(NotificationActionFixtures.event(location: "Room 4")))
        let linked = try #require(NotificationActionFixtures.planned(
            NotificationActionFixtures.event(location: "Room 4", url: NotificationActionFixtures.zoomURL)
        ))
        #expect(plain.id != linked.id)
    }

    @Test func eventsWithoutExtrasKeepTheirIdentifier() throws {
        let event = NotificationFixtures.event("plain", start: NotificationFixtures.hours(2))
        let planned = try #require(NotificationActionFixtures.planned(event))
        let candidate = NotificationCandidate(
            fireDate: planned.fireDate, kind: .event, reference: planned.reference, content: planned.content
        )
        #expect(planned.id == PlannedNotification(candidate).id)
    }

    @Test func userInfoRoundTripsTheContext() throws {
        let event = NotificationActionFixtures.event(
            location: "Tokyo Station", coordinate: NotificationActionFixtures.office, url: NotificationActionFixtures.zoomURL
        )
        let planned = try #require(NotificationActionFixtures.planned(event))
        let userInfo = NotificationUserInfo.make(for: planned)
        #expect(NotificationUserInfo.actionContext(from: userInfo) == planned.actionContext)
        #expect(NotificationUserInfo.item(from: userInfo)?.reference == event.reference)
    }
}
