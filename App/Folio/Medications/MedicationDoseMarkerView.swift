import Planner
import SwiftUI

/// Estimated doses are outlined with a dashed line so they never read as Health's own schedule.
struct MedicationDoseMarkerView: View {
    let marker: MedicationDoseMarker

    var body: some View {
        ViewThatFits(in: .horizontal) {
            pill(showsTitle: true)
            pill(showsTitle: false)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.trailing, 6)
    }

    private func pill(showsTitle: Bool) -> some View {
        HStack(spacing: 3) {
            Image(systemName: marker.status.systemImage)
            if showsTitle {
                Text(marker.title)
                    .lineLimit(1)
            }
        }
        .font(.caption2.weight(.medium))
        .foregroundStyle(Color.teal)
        .padding(.horizontal, 5)
        .frame(height: 18)
        .background(.background, in: Capsule())
        .background(Color.teal.opacity(isEstimated ? 0.06 : 0.16), in: Capsule())
        .overlay {
            Capsule()
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
