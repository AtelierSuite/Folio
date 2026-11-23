import Foundation
import Planner
import WidgetKit

nonisolated struct EnergyComplicationEntry: WidgetKit.TimelineEntry {
    let date: Date
    let curve: EnergyCurve
    let hour: Double

    init(date: Date, calendar: Calendar) {
        self.date = date
        let dayStart = calendar.startOfDay(for: date)
        curve = EnergyPreview.curve(forDayStarting: dayStart, calendar: calendar)
        hour = date.timeIntervalSince(dayStart) / 3600
    }

    var level: Double? {
        curve.level(atHour: hour)
    }

    var levelName: String {
        guard let level else { return String(localized: "Energy.Level.Resting", table: "Complications") }
        switch EnergyCurve.gaugeSegments(forLevel: level) {
        case 0: return String(localized: "Energy.Level.Low", table: "Complications")
        case 1: return String(localized: "Energy.Level.Steady", table: "Complications")
        case 2: return String(localized: "Energy.Level.High", table: "Complications")
        default: return String(localized: "Energy.Level.Peak", table: "Complications")
        }
    }
}
