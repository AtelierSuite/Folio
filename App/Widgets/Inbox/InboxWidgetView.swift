import Planner
import SwiftUI
import WidgetKit

struct InboxWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: FolioWidgetEntry

    private var items: [WidgetInboxItem] {
        entry.snapshot.inboxItems(at: entry.date)
    }

    var body: some View {
        content
            .widgetURL(CalendarDeepLink.url(forDay: entry.date))
    }

    @ViewBuilder
    private var content: some View {
        let snapshot = entry.snapshot
        if !snapshot.canReadEvents && !snapshot.canReadReminders {
            WidgetAccessRequiredView(kind: .event)
                .padding()
        } else {
            #if os(iOS)
            if family == .accessoryCircular {
                InboxCircularView(count: items.count)
            } else {
                list
            }
            #else
            list
            #endif
        }
    }

    private var list: some View {
        WidgetTitleBarLayout {
            WidgetTitleBar {
                Text(verbatim: String(localized: "Inbox.Name", table: "Widgets"))
                Spacer(minLength: 0)
                Text(items.count, format: .number)
                    .fontWeight(.regular)
            }
        } content: {
            InboxList(items: Array(items.prefix(family == .systemMedium ? 3 : 8)), date: entry.date)
        }
    }
}

struct InboxList: View {
    let items: [WidgetInboxItem]
    let date: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if items.isEmpty {
                InboxAllClearView()
            } else {
                ForEach(items) { item in
                    InboxRow(item: item, date: date)
                }
                Spacer(minLength: 0)
            }
        }
    }
}

struct InboxAllClearView: View {
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "checkmark.seal.fill")
                .font(.title2)
                .foregroundStyle(.green)
                .widgetAccentable()
            Text(verbatim: String(localized: "Inbox.AllClear", table: "Widgets"))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#if os(iOS)
struct InboxCircularView: View {
    let count: Int

    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "checklist")
                .font(.caption)
            Text(count, format: .number)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.6)
        }
        .accessibilityLabel(String(localized: "Inbox.Name", table: "Widgets"))
        .accessibilityValue(Text(count, format: .number))
    }
}
#endif
