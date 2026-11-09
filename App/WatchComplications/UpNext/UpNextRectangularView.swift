import Planner
import SwiftUI
import WidgetKit

struct UpNextRectangularView: View {
    let upNext: WidgetUpNext?
    let date: Date

    var body: some View {
        HStack(spacing: 6) {
            Capsule()
                .fill(upNext?.event.color.color ?? .secondary)
                .frame(width: 4)
                .widgetAccentable()
            VStack(alignment: .leading, spacing: 0) {
                if let upNext {
                    Text(upNext.event.title)
                        .font(.headline)
                        .lineLimit(1)
                        .privacySensitive()
                    Text(verbatim: upNext.timing(on: date, calendar: .current).summary)
                        .lineLimit(1)
                    if let location = upNext.event.location, !location.isEmpty {
                        Text(location)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .privacySensitive()
                    }
                } else {
                    Text(String(localized: "UpNext.Name", table: "Complications"))
                        .font(.headline)
                        .widgetAccentable()
                    Text(String(localized: "UpNext.Empty", table: "Complications"))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
