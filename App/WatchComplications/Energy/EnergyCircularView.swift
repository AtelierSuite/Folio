import SwiftUI
import WidgetKit

struct EnergyCircularView: View {
    let entry: EnergyComplicationEntry

    var body: some View {
        Gauge(value: entry.level ?? 0) {
            Image(systemName: "bolt.fill")
        } currentValueLabel: {
            Image(systemName: entry.level == nil ? "moon.zzz.fill" : "bolt.fill")
                .font(.title3)
        }
        .gaugeStyle(.accessoryCircularCapacity)
        .tint(.orange)
        .widgetAccentable()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(localized: "Energy.Title", table: "Complications"))
        .accessibilityValue(entry.levelName)
    }
}
