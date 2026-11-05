import Planner
import SwiftUI

struct EventLocationsSettingsSection: View {
    @State private var defaultLocation = EventLocationSettings().defaultLocation
    @State private var isChoosingDefault = false

    private var defaultLocationName: String {
        defaultLocation?.title ?? String(localized: "Settings.DefaultLocation.None", table: "Locations")
    }

    var body: some View {
        Section {
            LabeledContent(String(localized: "Settings.DefaultLocation", table: "Locations")) {
                Button(defaultLocationName) {
                    isChoosingDefault = true
                }
                .accessibilityIdentifier("DefaultLocationButton")
            }
            .sheet(isPresented: $isChoosingDefault) {
                EventLocationSearchView(location: $defaultLocation)
            }
        } header: {
            Text(String(localized: "Settings.Header", table: "Locations"))
        } footer: {
            Text(String(localized: "Settings.Footer", table: "Locations"))
        }
        .onChange(of: defaultLocation) { _, location in
            EventLocationSettings().defaultLocation = location
        }
    }
}
