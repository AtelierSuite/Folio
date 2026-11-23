import Foundation
import Planner

/// A glow strength blurred over about an hour, so peaks and the edges where a stretch starts
/// read as rounded hills instead of points when the whole day is squeezed into a complication.
nonisolated struct SmoothedEnergyStrength {
    private static let sigmaHours = 0.9
    private static let radiusHours = 2.7

    private let values: [Double]

    init(_ strength: (Double) -> Double) {
        let step = EnergyCurve.sampleStep
        let reach = Int((Self.radiusHours / step).rounded())
        let weights = (-reach...reach).map { offset in
            exp(-pow(Double(offset) * step, 2) / (2 * Self.sigmaHours * Self.sigmaHours))
        }
        let total = weights.reduce(0, +)
        let raw = (0..<EnergyCurve.sampleCount).map { strength(Double($0) * step) }
        values = raw.indices.map { index in
            zip(-reach...reach, weights).reduce(0) { sum, pair in
                let neighbour = min(max(index + pair.0, 0), raw.count - 1)
                return sum + raw[neighbour] * pair.1
            } / total
        }
    }

    /// The strength boosted and eased into full, so the color has no crease where it tops out.
    func intensity(_ hour: Double) -> Double {
        let boosted = min(self(hour) * 1.8, 1)
        return boosted * boosted * (3 - 2 * boosted)
    }

    func callAsFunction(_ hour: Double) -> Double {
        let position = min(max(hour, 0), 24) / EnergyCurve.sampleStep
        let lower = Int(position.rounded(.down))
        let upper = min(lower + 1, values.count - 1)
        let fraction = position - Double(lower)
        return values[lower] * (1 - fraction) + values[upper] * fraction
    }
}
