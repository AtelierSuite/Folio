import Planner
import SwiftUI
import WidgetKit

#if os(iOS)
struct UpNextRectangularView: View {
    let upNext: WidgetUpNext?
    let date: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let upNext {
                let event = upNext.event
                Text(event.title)
                    .font(.headline)
                    .widgetAccentable()
                    .lineLimit(1)
                Group {
                    if upNext.isOngoing {
                        Text(verbatim: upNext.timing(on: date, calendar: .current).summary)
                    } else {
                        WidgetEventTimeText(event: event, today: date)
                    }
                }
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
    let date: Date

    var body: some View {
        if let upNext {
            let timing = upNext.timing(on: date, calendar: .current)
            let line = "\(timing.summary) \(upNext.event.title)"
            ViewThatFits {
                Label {
                    Text(verbatim: line)
                } icon: {
                    Image(systemName: "calendar")
                }
                Text(verbatim: line)
            }
        } else {
            Label(String(localized: "UpNext.Empty", table: "Widgets"), systemImage: "calendar")
        }
    }
}

struct UpNextCircularView: View {
    let upNext: WidgetUpNext?
    let date: Date

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 0) {
                UpNextCircularHeader(timing: timing)
                if let timing {
                    Text(verbatim: timing.isOngoing ? timing.dayAndClock : timing.clock)
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

    private var timing: WidgetUpNextTiming? {
        upNext?.timing(on: date, calendar: .current)
    }
}

private struct UpNextCircularHeader: View {
    let timing: WidgetUpNextTiming?

    var body: some View {
        Group {
            if timing?.isOngoing == true {
                Image(systemName: "hourglass")
            } else if let weekday = timing?.weekday {
                Text(verbatim: weekday)
            } else {
                Image(systemName: "calendar")
            }
        }
        .font(.caption)
        .widgetAccentable()
    }
}
#endif
