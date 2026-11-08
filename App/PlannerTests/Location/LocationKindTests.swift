import MapKit
@testable import Planner
import Testing

struct LocationKindTests {
    @Test func addressesWithoutCategoryArePlaces() {
        #expect(LocationKind(category: nil) == .place)
    }

    @Test func unknownCategoriesArePlaces() {
        #expect(LocationKind(category: MKPointOfInterestCategory(rawValue: "Unknown")) == .place)
    }

    @Test(arguments: [
        (MKPointOfInterestCategory.restaurant, LocationKind.food),
        (.cafe, .cafe),
        (.hotel, .lodging),
        (.airport, .airport),
        (.publicTransport, .transit),
        (.hospital, .health),
        (.park, .nature),
        (.museum, .culture),
        (.stadium, .sports)
    ])
    func mapsCategories(category: MKPointOfInterestCategory, kind: LocationKind) {
        #expect(LocationKind(category: category) == kind)
    }

    @Test func mapsCategoriesAddedInLaterReleases() {
        guard #available(iOS 27.0, macOS 27.0, *) else { return }
        #expect(LocationKind(category: .airportTerminal) == .airport)
        #expect(LocationKind(category: .motorbikeDealership) == .car)
        #expect(LocationKind(category: .scenicView) == .nature)
        #expect(LocationKind(category: .ticketOffice) == .services)
    }
}
