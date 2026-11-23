import SwiftUI
import WidgetKit

struct EnergyComplicationView: View {
    let entry: EnergyComplicationEntry

    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            EnergyCircularView(entry: entry)
        case .accessoryCorner:
            EnergyCornerView(entry: entry)
        case .accessoryInline:
            Label(
                String(localized: "Energy.Inline \(entry.levelName)", table: "Complications"),
                systemImage: "bolt.fill"
            )
        default:
            EnergyRectangularView(entry: entry)
        }
    }
}
