import SwiftUI
import WidgetKit

/// The few hours around now from the energy glow, seen through the round complication,
/// with the bolt filled to the current level above it.
struct EnergyCurveCircularView: View {
    private static let hoursEachSide = 3.0

    let entry: EnergyComplicationEntry

    var body: some View {
        ZStack(alignment: .top) {
            AccessoryWidgetBackground()
            EnergyGlowStrip(
                curve: entry.curve,
                hour: entry.hour,
                window: (entry.hour - Self.hoursEachSide)...(entry.hour + Self.hoursEachSide),
                showsBaseline: false
            )
            .padding(.top, 21)
            .clipShape(Circle())
            EnergyLevelIcon(filledSegments: entry.filledSegments, size: 13)
                .padding(.top, 6)
                .widgetAccentable()
        }
        .clipShape(Circle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(localized: "Energy.Title", table: "Complications"))
        .accessibilityValue(entry.levelName)
    }
}
