import Planner
import SwiftUI

/// A bolt cut into bands that fill from the bottom, so the level reads without relying on color.
struct EnergyBoltGauge: View {
    let filledSegments: Int

    private let segmentCount = EnergyCurve.gaugeSegmentCount

    var body: some View {
        Image(systemName: "bolt")
            .overlay {
                Image(systemName: "bolt.fill")
                    .mask {
                        VStack(spacing: 0) {
                            ForEach(0..<segmentCount, id: \.self) { band in
                                Rectangle().opacity(band >= segmentCount - filledSegments ? 1 : 0)
                            }
                        }
                    }
            }
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(filledSegments == segmentCount ? AnyShapeStyle(.orange) : AnyShapeStyle(.secondary))
    }
}
