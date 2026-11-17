import Foundation

/// A rough estimate of alertness through one day, from the three-process model of alertness
/// (Åkerstedt and Folkard): sleep pressure, the body clock and waking grogginess, plus the
/// early-afternoon dip. Strengths run from 0 to 1 and are sampled every `sampleStep` hours.
public struct EnergyCurve: Sendable, Equatable {
    public static let sampleStep = 1.0 / 12
    public static let sampleCount = Int(24 / sampleStep) + 1

    public let peakStrengths: [Double]
    public let lowStrengths: [Double]
    public let markers: [EnergyMarker]

    public init(_ inputs: EnergyInputs) {
        let model = EnergyModel(inputs)
        let hours = (0..<Self.sampleCount).map { Double($0) * Self.sampleStep }
        let levels = model.normalizedLevels(at: hours)
        peakStrengths = levels.map { level in
            guard let level else { return 0 }
            return pow(max(0, (level - 0.62) / 0.38), 1.4)
        }
        lowStrengths = hours.enumerated().map { index, hour in
            guard levels[index] != nil else { return 0 }
            return max(model.dipStrength(at: hour), model.windDownStrength(at: hour))
        }
        markers = model.markers(hours: hours, levels: levels)
    }

    public func peakStrength(atHour hour: Double) -> Double {
        Self.interpolate(peakStrengths, atHour: hour)
    }

    public func lowStrength(atHour hour: Double) -> Double {
        Self.interpolate(lowStrengths, atHour: hour)
    }

    private static func interpolate(_ values: [Double], atHour hour: Double) -> Double {
        let position = min(max(hour, 0), 24) / sampleStep
        let lower = Int(position.rounded(.down))
        let upper = min(lower + 1, values.count - 1)
        let fraction = position - Double(lower)
        return values[lower] * (1 - fraction) + values[upper] * fraction
    }
}
