import Planner
import SwiftUI

/// Estimated doses are outlined with a dashed line so they never read as Health's own schedule.
struct MedicationDoseMarkerView: View {
    let marker: MedicationDoseMarker

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: marker.status.systemImage)
            Text(marker.title)
                .lineLimit(1)
        }
        .font(.caption2.weight(.medium))
        .foregroundStyle(Color.teal)
        .padding(.horizontal, 5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 18)
        .background(.background, in: Rectangle())
        .background(Color.teal.opacity(isEstimated ? 0.06 : 0.16), in: Rectangle())
        .overlay {
            Rectangle()
                .strokeBorder(
                    Color.teal.opacity(0.6),
                    style: StrokeStyle(lineWidth: 1, dash: isEstimated ? [3, 2] : [])
                )
        }
    }

    private var isEstimated: Bool {
        marker.status == .estimated
    }
}
