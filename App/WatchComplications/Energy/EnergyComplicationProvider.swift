import Foundation
import Planner
import WidgetKit

nonisolated struct EnergyComplicationProvider: AppIntentTimelineProvider {
    private static let tickInterval: TimeInterval = 15 * 60

    /// Shown as the complication's name in the watch face editor.
    let recommendationTitle: String

    func recommendations() -> [AppIntentRecommendation<ComplicationConfigurationIntent>] {
        [AppIntentRecommendation(intent: ComplicationConfigurationIntent(), description: recommendationTitle)]
    }

    func placeholder(in context: Context) -> EnergyComplicationEntry {
        EnergyComplicationEntry(date: .now, calendar: .current)
    }

    func snapshot(
        for configuration: ComplicationConfigurationIntent,
        in context: Context
    ) async -> EnergyComplicationEntry {
        EnergyComplicationEntry(date: .now, calendar: .current)
    }

    func timeline(
        for configuration: ComplicationConfigurationIntent,
        in context: Context
    ) async -> Timeline<EnergyComplicationEntry> {
        let calendar = Calendar.current
        let now = Date.now
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now)) ?? now
        let entries = stride(from: now, to: tomorrow, by: Self.tickInterval)
            .map { EnergyComplicationEntry(date: $0, calendar: calendar) }
        return Timeline(entries: entries, policy: .after(tomorrow))
    }
}
