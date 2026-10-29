import Planner
import SwiftUI
import WidgetKit

#if os(iOS)
struct UpNextRectangularView: View {
    let upNext: WidgetUpNext?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let event = upNext?.event {
                Text(event.title)
                    .font(.headline)
                    .widgetAccentable()
                    .lineLimit(1)
                WidgetEventTimeText(event: event)
                    .lineLimit(1)
                if let location = event.location, !location.isEmpty {
                    Text(location)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            } else {
                Text(String(localized: "UpNext.Title", table: "Widgets"))
                    .font(.headline)
                    .widgetAccentable()
                Text(String(localized: "UpNext.Empty", table: "Widgets"))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct UpNextInlineView: View {
    let upNext: WidgetUpNext?

    var body: some View {
        if let event = upNext?.event {
            Label {
                Text(verbatim: "\(WidgetEventTimeText.time(event.startDate)) \(event.title)")
            } icon: {
                Image(systemName: "calendar")
            }
        } else {
            Label(String(localized: "UpNext.Empty", table: "Widgets"), systemImage: "calendar")
        }
    }
}

struct UpNextCircularView: View {
    let upNext: WidgetUpNext?

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 0) {
                Image(systemName: "calendar")
                    .font(.caption)
                    .widgetAccentable()
                if let event = upNext?.event {
                    Text(event.startDate, format: .dateTime.hour(.defaultDigits(amPM: .omitted)).minute())
                        .font(.caption2.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                } else {
                    Text(verbatim: "–")
                        .font(.caption2)
                }
            }
            .padding(4)
        }
    }
}
#endif
