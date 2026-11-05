import Planner
import SwiftUI

/// Drawn like a timed reminder card, with the pills icon in place of the checkbox. The solid layer
/// keeps the marker readable where it sits on top of an event.
struct MedicationDoseMarkerView: View {
    let marker: MedicationDoseMarker

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "pills.fill")
                .foregroundStyle(Color.teal.opacity(isEstimated ? 0.6 : 1))
            Text(marker.title)
                .fontWeight(.semibold)
                .strikethrough(marker.status == .taken)
                .foregroundStyle(isFinished ? .secondary : .primary)
                .lineLimit(1)
        }
        .font(.caption)
        .padding(.leading, 6)
        .padding(.trailing, 3)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color.teal.opacity(fillOpacity), in: Rectangle())
        .background(.background, in: Rectangle())
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(Color.teal.opacity(isEstimated ? 0.5 : 1))
                .frame(width: 3)
        }
        .padding(1)
    }

    private var isEstimated: Bool {
        marker.status == .estimated
    }

    private var isFinished: Bool {
        marker.status == .taken || marker.status == .skipped
    }

    private var fillOpacity: Double {
        if isFinished { return 0.1 }
        return isEstimated ? 0.12 : 0.22
    }
}
