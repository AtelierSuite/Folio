import Foundation

/// What the energy estimate is built from, in wall clock hours of the day being estimated.
public struct EnergyInputs: Sendable, Equatable {
    public var wakeHour: Double
    public var sleepHours: Double
    public var sleepDebtHours: Double
    /// When heart rate bottoms out overnight. Without heart rate it falls 2.5 hours before waking.
    public var bodyClockLowHour: Double

    public init(wakeHour: Double, sleepHours: Double, sleepDebtHours: Double = 0, bodyClockLowHour: Double? = nil) {
        self.wakeHour = wakeHour
        self.sleepHours = sleepHours
        self.sleepDebtHours = sleepDebtHours
        self.bodyClockLowHour = bodyClockLowHour ?? wakeHour - 2.5
    }
}
