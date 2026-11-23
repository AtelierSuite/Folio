import SwiftUI
import WidgetKit

/// Today's energy as a line, brighter up to now, with a dot on the current level.
struct EnergyRectangularView: View {
    let entry: EnergyComplicationEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: "bolt.fill")
                    .foregroundStyle(.orange)
                    .widgetAccentable()
                Text(String(localized: "Energy.Title", table: "Complications"))
                    .font(.headline)
                    .widgetAccentable()
                Spacer(minLength: 0)
                Text(entry.levelName)
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            EnergyLineGraph(curve: entry.curve, hour: entry.hour)
                .frame(maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(localized: "Energy.Title", table: "Complications"))
        .accessibilityValue(entry.levelName)
    }
}
