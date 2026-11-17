import Foundation
import Planner

/// Sample energy curves for trying the glow before it reads real Health data.
enum EnergyPreview {
    static let launchArgument = "-EnergyPreview"

    static var isEnabled: Bool {
        #if DEBUG
        ProcessInfo.processInfo.arguments.contains(launchArgument)
        #else
        false
        #endif
    }

    static func curve(forDayStarting dayStart: Date, calendar: Calendar) -> EnergyCurve {
        let day = calendar.ordinality(of: .day, in: .era, for: dayStart) ?? 0
        let wakeHour = 6.75 + Double(day % 3) * 0.25
        let sleepHours = day.isMultiple(of: 2) ? 7.5 : 6.25
        return EnergyCurve(EnergyInputs(wakeHour: wakeHour, sleepHours: sleepHours, sleepDebtHours: 3))
    }
}
