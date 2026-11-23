import SwiftUI
import WidgetKit

struct EnergyCornerView: View {
    let entry: EnergyComplicationEntry

    var body: some View {
        Image(systemName: entry.level == nil ? "moon.zzz.fill" : "bolt.fill")
            .font(.title3)
            .foregroundStyle(.orange)
            .widgetAccentable()
            .widgetLabel {
                Gauge(value: entry.level ?? 0) {
                    Text(entry.levelName)
                }
                .tint(.orange)
            }
            .accessibilityLabel(String(localized: "Energy.Title", table: "Complications"))
            .accessibilityValue(entry.levelName)
    }
}
