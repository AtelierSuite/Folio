import Planner
import SwiftUI
import WidgetKit

struct UpNextSmallView: View {
    let upNext: WidgetUpNext?

    var body: some View {
        if let upNext {
            VStack(alignment: .leading, spacing: 4) {
                UpNextHeading(isOngoing: upNext.isOngoing)
                UpNextEventSummary(event: upNext.event)
                Spacer(minLength: 0)
                UpNextFooter(upNext: upNext)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        } else {
            VStack(alignment: .leading, spacing: 4) {
                UpNextHeading(isOngoing: false)
                WidgetEmptyText(text: String(localized: "UpNext.Empty", table: "Widgets"))
            }
        }
    }
}

struct UpNextHeading: View {
    let isOngoing: Bool

    var body: some View {
        Text(String(localized: isOngoing ? "UpNext.Now" : "UpNext.Title", table: "Widgets"))
            .font(.caption2.weight(.bold))
            .textCase(.uppercase)
            .foregroundStyle(.tint)
            .widgetAccentable()
    }
}

struct UpNextEventSummary: View {
    let event: CalendarEvent

    var body: some View {
        HStack(spacing: 6) {
            WidgetColorBar(color: event.color)
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)
                WidgetEventTimeText(event: event)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let location = event.location, !location.isEmpty {
                    Text(location)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct UpNextFooter: View {
    let upNext: WidgetUpNext

    var body: some View {
        if let joinURL = upNext.joinURL {
            JoinMeetingButton(url: joinURL, brandColor: upNext.meetingBrandColor)
        } else if !upNext.isOngoing {
            Text("UpNext.StartsIn \(Text(upNext.event.startDate, style: .relative))", tableName: "Widgets")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }
}
