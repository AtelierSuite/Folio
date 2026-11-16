import Planner
import SwiftUI

struct TimelineMedicationCardView: View {
    @Environment(\.medicationDoseMarkers) private var markers
    @Environment(\.openURL) private var openURL
    let entry: TimelineEntry

    var body: some View {
        if let marker = markers[entry.id] {
            Button {
                openURL(HealthApp.browseURL)
            } label: {
                MedicationDoseMarkerView(marker: marker)
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(marker.accessibilityLabel)
            .accessibilityHint(String(localized: "Marker.OpenHealthHint", table: "Medications"))
            .accessibilityAddTraits(.isButton)
            .accessibilityIdentifier("MedicationDoseMarker")
        }
    }
}
