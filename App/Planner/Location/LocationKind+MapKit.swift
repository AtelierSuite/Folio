import MapKit

extension LocationKind {
    init(category: MKPointOfInterestCategory?) {
        guard let category else {
            self = .place
            return
        }
        self = Self.kindsByCategory[category] ?? .place
    }

    private static let kindsByCategory: [MKPointOfInterestCategory: LocationKind] = [
        .restaurant: .food, .bakery: .food,
        .cafe: .cafe,
        .nightlife: .drinks, .brewery: .drinks, .winery: .drinks, .distillery: .drinks,
        .store: .shopping,
        .foodMarket: .groceries,
        .hotel: .lodging, .campground: .lodging, .rvPark: .lodging,
        .airport: .airport, .newer("MKPOICategoryAirportTerminal"): .airport,
        .publicTransport: .transit,
        .parking: .car, .carRental: .car, .automotiveRepair: .car, .newer("MKPOICategoryAutomotiveDealership"): .car,
        .newer("MKPOICategoryCommercialVehicleDealership"): .car, .newer("MKPOICategoryMotorbikeDealership"): .car,
        .gasStation: .fuel,
        .evCharger: .charging,
        .hospital: .health, .pharmacy: .health,
        .school: .education, .university: .education, .library: .education,
        .park: .nature, .nationalPark: .nature, .hiking: .nature, .newer("MKPOICategoryPicnicArea"): .nature,
        .newer("MKPOICategoryRangerStation"): .nature, .newer("MKPOICategoryScenicView"): .nature,
        .newer("MKPOICategoryRestArea"): .nature,
        .beach: .water, .marina: .water, .kayaking: .water, .surfing: .water,
        .swimming: .water, .fishing: .water,
        .museum: .culture, .castle: .culture, .fortress: .culture, .landmark: .culture,
        .nationalMonument: .culture, .planetarium: .culture,
        .movieTheater: .entertainment, .theater: .entertainment, .musicVenue: .entertainment,
        .amusementPark: .entertainment, .aquarium: .entertainment, .zoo: .entertainment,
        .fairground: .entertainment, .bowling: .entertainment, .miniGolf: .entertainment,
        .goKart: .entertainment, .conventionCenter: .entertainment,
        .fitnessCenter: .sports, .stadium: .sports, .baseball: .sports, .basketball: .sports,
        .golf: .sports, .soccer: .sports, .tennis: .sports, .volleyball: .sports,
        .skating: .sports, .skatePark: .sports, .skiing: .sports, .rockClimbing: .sports,
        .bank: .finance, .atm: .finance,
        .police: .services, .fireStation: .services, .postOffice: .services, .mailbox: .services,
        .laundry: .services, .beauty: .services, .spa: .services, .animalService: .services,
        .newer("MKPOICategoryVisitorCenter"): .services, .newer("MKPOICategoryInformationBooth"): .services,
        .newer("MKPOICategoryTicketOffice"): .services,
        .restroom: .services
    ]
}

private extension MKPointOfInterestCategory {
    // Categories added in iOS 27, matched by raw value so iOS 26 builds keep compiling.
    static func newer(_ rawValue: String) -> Self {
        Self(rawValue: rawValue)
    }
}
