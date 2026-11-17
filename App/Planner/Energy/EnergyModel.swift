import Foundation

struct EnergyModel {
    private static let sleepPressureFloor = 2.4
    private static let sleepPressureCeiling = 14.3
    private static let sleepPressureAtBedtime = 6.2
    private static let sleepPressureDecay = 0.0353
    private static let sleepRecoveryRate = 0.381
    private static let sleepDebtWeight = 0.18
    private static let bodyClockAmplitude = 2.5
    private static let bodyClockPeakAfterLow = 12.3
    private static let grogginessDepth = 5.0
    private static let grogginessRecovery = 1.51
    private static let dipDepth = 1.6
    private static let dipBeforeBodyClockPeak = 2.6
    private static let groggyHours = 1.5
    private static let peakThreshold = 0.75

    let inputs: EnergyInputs
    private let pressureOnWaking: Double
    private let bodyClockPeakHour: Double

    init(_ inputs: EnergyInputs) {
        self.inputs = inputs
        let deficit = Self.sleepPressureCeiling - Self.sleepPressureAtBedtime
        let recovered = Self.sleepPressureCeiling - deficit * exp(-Self.sleepRecoveryRate * inputs.sleepHours)
        pressureOnWaking = recovered - Self.sleepDebtWeight * inputs.sleepDebtHours
        bodyClockPeakHour = inputs.bodyClockLowHour + Self.bodyClockPeakAfterLow
    }

    var dipHour: Double {
        bodyClockPeakHour - Self.dipBeforeBodyClockPeak
    }

    func alertness(at hour: Double) -> Double? {
        let hoursAwake = hour - inputs.wakeHour
        guard hoursAwake >= 0 else { return nil }
        let pressure = Self.sleepPressureFloor
            + (pressureOnWaking - Self.sleepPressureFloor) * exp(-Self.sleepPressureDecay * hoursAwake)
        let bodyClock = Self.bodyClockAmplitude * cos(2 * .pi * (hour - bodyClockPeakHour) / 24)
        let grogginess = -Self.grogginessDepth * exp(-Self.grogginessRecovery * hoursAwake)
        let dip = -Self.dipDepth * exp(-pow(hour - dipHour, 2) / 2)
        return pressure + bodyClock + grogginess + dip
    }

    /// Scaled against the waking day after the first groggy stretch, so grogginess doesn't flatten it.
    func normalizedLevels(at hours: [Double]) -> [Double?] {
        let raw = hours.map(alertness(at:))
        let settled = zip(hours, raw).compactMap { hour, value in
            hour >= inputs.wakeHour + Self.groggyHours ? value : nil
        }
        guard let lowest = settled.min(), let highest = settled.max(), highest > lowest else {
            return raw.map { $0.map { _ in 0 } }
        }
        return raw.map { value in
            value.map { min(max(($0 - lowest) / (highest - lowest), 0), 1) }
        }
    }

    func dipStrength(at hour: Double) -> Double {
        exp(-pow(hour - dipHour, 2) / (2 * 0.55 * 0.55))
    }

    func windDownStrength(at hour: Double) -> Double {
        min(max((hour - (bodyClockPeakHour + 4)) / 1.2, 0), 1)
    }

    func markers(hours: [Double], levels: [Double?]) -> [EnergyMarker] {
        var peaks: [EnergyMarker] = []
        for index in hours.indices.dropFirst().dropLast() {
            guard hours[index] >= inputs.wakeHour + Self.groggyHours,
                  let level = levels[index], let previous = levels[index - 1], let next = levels[index + 1],
                  level >= Self.peakThreshold, level >= previous, level > next else { continue }
            peaks.append(EnergyMarker(kind: .peak, hour: hours[index]))
        }
        var markers = peaks
        if dipHour > inputs.wakeHour + Self.groggyHours {
            markers.append(EnergyMarker(kind: .dip, hour: dipHour))
        }
        let windDownHour = bodyClockPeakHour + 4.6
        if windDownHour < 24 {
            markers.append(EnergyMarker(kind: .windDown, hour: windDownHour))
        }
        return markers.sorted { $0.hour < $1.hour }
    }
}
