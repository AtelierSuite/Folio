import Planner
import SwiftUI

struct EventLocationsSettingsSection: View {
    @State private var defaultLocation = EventLocationSettings().defaultLocation
    @State private var savedLocations = EventLocationSettings().savedLocations
    @State private var isChoosingDefault = false
    @State private var isAddingSavedLocation = false

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
            ForEach(savedLocations) { saved in
                SavedLocationRow(saved: saved, onSave: update, onDelete: delete)
            }
            .onDelete { savedLocations.remove(atOffsets: $0) }
            Button(String(localized: "Settings.Add", table: "Locations")) {
                isAddingSavedLocation = true
            }
            .accessibilityIdentifier("AddSavedLocationButton")
            .sheet(isPresented: $isAddingSavedLocation) {
                SavedLocationEditorView { savedLocations.append($0) }
            }
        } header: {
            Text(String(localized: "Settings.Header", table: "Locations"))
        } footer: {
            Text(String(localized: "Settings.Footer", table: "Locations"))
        }
        .onChange(of: defaultLocation) { _, location in
            EventLocationSettings().defaultLocation = location
        }
        .onChange(of: savedLocations) { _, locations in
            EventLocationSettings().savedLocations = locations
        }
    }

    private func update(_ saved: SavedLocation) {
        guard let index = savedLocations.firstIndex(where: { $0.id == saved.id }) else { return }
        savedLocations[index] = saved
    }

    private func delete(_ saved: SavedLocation) {
        savedLocations.removeAll { $0.id == saved.id }
    }
}
