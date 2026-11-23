import Planner
import SwiftUI

/// The app's segmented bolt filled to the current level, or a moon before waking.
struct EnergyLevelIcon: View {
    let filledSegments: Int?
    let size: CGFloat

    var body: some View {
        if let filledSegments {
            EnergyBoltGauge(filledSegments: filledSegments, size: size)
        } else {
            Image(systemName: "moon.zzz.fill")
                .font(.system(size: size, weight: .semibold))
                .foregroundStyle(.secondary)
        }
    }
}
