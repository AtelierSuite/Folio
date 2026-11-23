import SwiftUI

/// A bolt cut into bands that fill from the bottom, so the level reads without relying on color.
public struct EnergyBoltGauge: View {
    let filledSegments: Int
    let size: CGFloat

    private let segmentCount = EnergyCurve.gaugeSegmentCount

    public init(filledSegments: Int, size: CGFloat = 12) {
        self.filledSegments = filledSegments
        self.size = size
    }

    public var body: some View {
        // The outline is masked to the empty bands so it never sits under the fill,
        // where a translucent .secondary would double up and draw a lighter inner bolt.
        ZStack {
            Image(systemName: "bolt")
                .mask { bands(filled: false) }
            Image(systemName: "bolt.fill")
                .mask { bands(filled: true) }
        }
        .font(.system(size: size, weight: .semibold))
        .foregroundStyle(filledSegments == segmentCount ? AnyShapeStyle(.orange) : AnyShapeStyle(.secondary))
    }

    private func bands(filled: Bool) -> some View {
        VStack(spacing: 0) {
            ForEach(0..<segmentCount, id: \.self) { band in
                Rectangle().opacity((band >= segmentCount - filledSegments) == filled ? 1 : 0)
            }
        }
    }
}
