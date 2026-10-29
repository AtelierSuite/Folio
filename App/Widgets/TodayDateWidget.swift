import SwiftUI
import WidgetKit

struct TodayDateWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "TodayDateWidget", provider: TodayDateProvider()) { entry in
            TodayDateWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Folio")
        .supportedFamilies([.systemSmall])
    }
}

struct TodayDateEntry: TimelineEntry {
    let date: Date
}

struct TodayDateProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodayDateEntry {
        TodayDateEntry(date: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (TodayDateEntry) -> Void) {
        completion(TodayDateEntry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodayDateEntry>) -> Void) {
        let tomorrow = Calendar.current.startOfDay(for: .now.addingTimeInterval(86_400))
        completion(Timeline(entries: [TodayDateEntry(date: .now)], policy: .after(tomorrow)))
    }
}

struct TodayDateWidgetView: View {
    let entry: TodayDateEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(entry.date, format: .dateTime.weekday(.wide))
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tint)
            Text(entry.date, format: .dateTime.day())
                .font(.system(size: 44, weight: .bold, design: .rounded))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
