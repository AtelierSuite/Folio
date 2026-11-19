import Planner
import SwiftUI

struct TravelOriginPicker: View {
    @Environment(TravelTimeStore.self) private var travelTime

    var body: some View {
        Picker(String(localized: "Settings.FirstEventOrigin", table: "TravelTime"), selection: Binding(
            get: { travelTime.firstEventOrigin },
            set: { travelTime.setFirstEventOrigin($0) }
        )) {
            ForEach(TravelOrigin.allCases) { origin in
                Text(origin.title).tag(origin)
            }
        }
        .accessibilityIdentifier("TravelTimeFirstEventOriginPicker")
        if travelTime.firstEventOrigin == .specificLocation {
            EventLocationRow(
                location: Binding(
                    get: { travelTime.startingLocation },
                    set: { travelTime.setStartingLocation($0) }
                ),
                placeholder: String(localized: "Settings.StartingLocation", table: "TravelTime")
            )
            .accessibilityIdentifier("TravelTimeStartingLocationRow")
        }
    }
}

extension TravelOrigin {
    var title: String {
        switch self {
        case .currentLocation: String(localized: "Origin.CurrentLocation", table: "TravelTime")
        case .specificLocation: String(localized: "Origin.SpecificLocation", table: "TravelTime")
        }
    }
}
