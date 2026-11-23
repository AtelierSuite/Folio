import SwiftUI
import WidgetKit

struct EnergyRectangularView: View {
    let entry: EnergyComplicationEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 4) {
                EnergyLevelIcon(filledSegments: entry.filledSegments, size: 15)
                    .widgetAccentable()
                Text(String(localized: "Energy.Title", table: "Complications"))
                    .font(.headline)
                    .widgetAccentable()
                Spacer(minLength: 0)
                Text(entry.levelName)
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            EnergyGlowStrip(curve: entry.curve, hour: entry.hour)
                .frame(maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(localized: "Energy.Title", table: "Complications"))
        .accessibilityValue(entry.levelName)
    }
}
