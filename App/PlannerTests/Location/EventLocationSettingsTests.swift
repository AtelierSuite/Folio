import Foundation
@testable import Planner
import Testing

struct EventLocationSettingsTests {
    private let office = EventLocation(
        title: "Tokyo Tower",
        address: "Minato, Tokyo",
        coordinate: EventCoordinate(latitude: 35.6586, longitude: 139.7454)
    )

    private func makeSettings() throws -> EventLocationSettings {
        let defaults = try #require(UserDefaults(suiteName: "EventLocationSettingsTests.\(UUID().uuidString)"))
        return EventLocationSettings(defaults: defaults)
    }

    @Test func startsWithNoLocations() throws {
        let settings = try makeSettings()
        #expect(settings.defaultLocation == nil)
        #expect(settings.savedLocations.isEmpty)
    }

    @Test func keepsTheDefaultLocationWithItsCoordinate() throws {
        let settings = try makeSettings()
        settings.defaultLocation = office
        #expect(settings.defaultLocation == office)
        settings.defaultLocation = nil
        #expect(settings.defaultLocation == nil)
    }

    @Test func keepsSavedLocationsInOrder() throws {
        let settings = try makeSettings()
        let saved = [
            SavedLocation(name: "Work", location: office),
            SavedLocation(name: "Home", location: EventLocation(title: "1-2-3 Shibuya"))
        ]
        settings.savedLocations = saved
        #expect(settings.savedLocations == saved)
    }

    @Test func matchesByNameOrPlace() {
        let saved = SavedLocation(name: "Work", location: office)
        #expect(saved.matches("wor"))
        #expect(saved.matches("tower"))
        #expect(saved.matches("minato"))
        #expect(!saved.matches("home"))
    }

    @Test func summarizesTheTitleAndAddress() {
        #expect(SavedLocation(name: "Work", location: office).summary == "Tokyo Tower, Minato, Tokyo")
        #expect(SavedLocation(name: "Home", location: EventLocation(title: "Shibuya")).summary == "Shibuya")
    }

    @Test func newEventStartsAtTheGivenLocation() {
        let draft = EventDraft.newEvent(on: .now, calendarIdentifier: "", location: office)
        #expect(draft.location == office)
        #expect(EventDraft.newEvent(on: .now, calendarIdentifier: "").location == nil)
    }
}
