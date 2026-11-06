import SwiftUI
import WidgetKit

#if os(iOS)
struct WidgetAccessoryAccessRequiredView: View {
    @Environment(\.widgetFamily) private var family
    let systemImage: String

    var body: some View {
        switch family {
        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                VStack(spacing: 0) {
                    Image(systemName: systemImage)
                        .font(.caption)
                        .widgetAccentable()
                    Text(String(localized: "Access.Short", table: "Widgets"))
                        .font(.caption2.weight(.semibold))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.6)
                }
                .padding(4)
            }
        case .accessoryRectangular:
            Text(String(localized: "Access.Title", table: "Widgets"))
                .font(.headline)
                .widgetAccentable()
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
        default:
            Label(String(localized: "Access.Short", table: "Widgets"), systemImage: systemImage)
        }
    }
}
#endif
