import Foundation
import Testing
@testable import Planner

struct NotificationPlaceTests {
    private func roomEvent(_ room: String) -> CalendarEvent {
        NotificationActionFixtures.event(location: room)
    }

    @Test func linkOnlyLocationIsNotAPlace() {
        #expect(NotificationPlace(event: NotificationActionFixtures.event(location: "https://zoom.us/j/1")) == nil)
        #expect(NotificationPlace(event: NotificationActionFixtures.event(location: " ")) == nil)
    }

    @Test func addressOrCoordinateMakesAPlace() {
        let address = NotificationPlace(event: NotificationActionFixtures.event(location: "  1 Infinite Loop  "))
        #expect(address?.name == "1 Infinite Loop")
        let pinnedEvent = NotificationActionFixtures.event(coordinate: NotificationActionFixtures.office)
        let pinned = NotificationPlace(event: pinnedEvent)
        #expect(pinned?.coordinate == NotificationActionFixtures.office)
    }

    @Test func directionsUseCoordinatesWhenKnown() throws {
        let place = try #require(
            NotificationPlace(name: "Tokyo Station", coordinate: NotificationActionFixtures.office)
        )
        let url = try #require(place.directionsURL)
        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        #expect(url.host() == "maps.apple.com")
        #expect(items.first { $0.name == "daddr" }?.value == "35.6812,139.7671")
        #expect(items.first { $0.name == "q" }?.value == "Tokyo Station")
    }

    @Test func directionsFallBackToTheAddress() throws {
        let place = try #require(NotificationPlace(name: "1 Infinite Loop, Cupertino", coordinate: nil))
        let url = try #require(place.directionsURL)
        let items = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems)
        #expect(items == [URLQueryItem(name: "daddr", value: "1 Infinite Loop, Cupertino")])
    }

    @Test func plannedEventsPickTheirCategoryFromTheMeetingAndPlace() throws {
        let event = NotificationActionFixtures.event(location: "Room 4", url: NotificationActionFixtures.zoomURL)
        let planned = try #require(NotificationActionFixtures.planned(event))
        #expect(planned.category == .eventWithMeetingAndPlace)
        #expect(planned.meeting?.link.url == NotificationActionFixtures.zoomURL)
        #expect(planned.place?.name == "Room 4")
        let linkOnly = try #require(NotificationActionFixtures.planned(
            NotificationActionFixtures.event(location: "https://zoom.us/j/123")
        ))
        #expect(linkOnly.category == .eventWithMeeting)
    }

    @Test func eventsWithoutExtrasKeepTheirIdentifier() throws {
        let event = NotificationFixtures.event("plain", start: NotificationFixtures.hours(2))
        let planned = try #require(NotificationActionFixtures.planned(event))
        let candidate = NotificationCandidate(
            fireDate: planned.fireDate, kind: .event, reference: planned.reference, content: planned.content
        )
        #expect(planned.id == PlannedNotification(candidate).id)
    }

    @Test func movingThePlaceReschedulesTheAlert() throws {
        let first = try #require(NotificationActionFixtures.planned(roomEvent("Room 4")))
        let second = try #require(NotificationActionFixtures.planned(roomEvent("Room 5")))
        #expect(first.id != second.id)
    }

    @Test func restylingKeepsTheMeetingAndPlace() throws {
        let event = NotificationActionFixtures.event(location: "Room 4", url: NotificationActionFixtures.zoomURL)
        let planned = try #require(NotificationActionFixtures.planned(event))
        let restyled = planned.restyled(.timeSensitive)
        #expect(restyled.meeting == planned.meeting)
        #expect(restyled.place == planned.place)
        #expect(restyled.category == .eventWithMeetingAndPlace)
    }

    @Test func userInfoRoundTripsThePlace() throws {
        let event = NotificationActionFixtures.event(
            location: "Tokyo Station",
            coordinate: NotificationActionFixtures.office,
            url: NotificationActionFixtures.zoomURL
        )
        let planned = try #require(NotificationActionFixtures.planned(event))
        let userInfo = NotificationUserInfo.make(for: planned)
        #expect(NotificationUserInfo.place(from: userInfo) == planned.place)
        #expect(NotificationUserInfo.meeting(from: userInfo) == planned.meeting)
        #expect(NotificationUserInfo.item(from: userInfo)?.reference == event.reference)
    }
}
