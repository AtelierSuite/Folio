import SwiftUI
import WidgetKit

/// Shown until calendar access is allowed in the watch app.
struct ComplicationAccessView: View {
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .accessoryCircular, .accessoryCorner:
            ZStack {
                AccessoryWidgetBackground()
                Image(systemName: "lock.fill")
                    .widgetAccentable()
            }
            .widgetLabel(String(localized: "Access.Required", table: "Complications"))
        case .accessoryInline:
            Label(String(localized: "Access.Required", table: "Complications"), systemImage: "lock.fill")
        default:
            VStack(alignment: .leading, spacing: 0) {
                Label(String(localized: "Access.Required", table: "Complications"), systemImage: "lock.fill")
                    .font(.headline)
                    .widgetAccentable()
                Text(String(localized: "Access.Message", table: "Complications"))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
