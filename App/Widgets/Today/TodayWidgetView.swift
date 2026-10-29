import Planner
import SwiftUI
import WidgetKit

struct TodayWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: FolioWidgetEntry

    var body: some View {
        content
            .widgetURL(CalendarDeepLink.url(forDay: entry.date))
    }

    @ViewBuilder
    private var content: some View {
        let snapshot = entry.snapshot
        if !snapshot.canReadEvents && !snapshot.canReadReminders {
            WidgetAccessRequiredView(kind: .event)
        } else if family == .systemMedium {
            HStack(alignment: .top, spacing: 12) {
                TodayDateHeader(date: entry.date)
                    .frame(width: 64, alignment: .leading)
                TodayAgendaList(entry: entry, rowLimit: 4)
            }
        } else {
            VStack(alignment: .leading, spacing: 8) {
                TodayDateHeader(date: entry.date)
                TodayAgendaList(entry: entry, rowLimit: family == .systemExtraLarge ? 12 : 9)
            }
        }
    }
}

struct TodayDateHeader: View {
    let date: Date

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 0) {
                Text(date, format: .dateTime.weekday(.wide))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tint)
                    .widgetAccentable()
                Text(date, format: .dateTime.day())
                    .font(.system(size: 34, weight: .bold, design: .rounded))
            }
            Spacer(minLength: 0)
            WidgetWeatherSlot(date: date)
        }
    }
}
