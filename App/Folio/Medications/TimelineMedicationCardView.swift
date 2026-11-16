import Planner
import SwiftUI

struct TimelineMedicationCardView: View {
    @Environment(\.medicationDoseMarkers) private var markers
    let entry: TimelineEntry

    var body: some View {
        if let marker = markers[entry.id] {
            MedicationDoseMarkerView(marker: marker)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(marker.accessibilityLabel)
                .accessibilityIdentifier("MedicationDoseMarker")
        }
    }
}
