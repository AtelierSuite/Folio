import Planner
import SwiftUI
import WidgetKit

struct EventNotesWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: FolioWidgetEntry

    private var eventNote: WidgetEventNote? {
        entry.snapshot.nextEventNote(at: entry.date)
    }

    var body: some View {
        content
            .widgetURL(eventNote?.digest.noteURL ?? CalendarDeepLink.url(forDay: entry.date))
    }

    @ViewBuilder
    private var content: some View {
        if !entry.snapshot.canReadEvents {
            WidgetAccessRequiredView(kind: .event)
                .padding()
        } else if let eventNote {
            WidgetTitleBarLayout {
                EventNotesTitleBar(eventNote: eventNote)
            } content: {
                if family == .systemLarge {
                    EventNotesLargeView(eventNote: eventNote, badges: entry.snapshot.contactBadges)
                } else {
                    EventNotesMediumView(eventNote: eventNote, badges: entry.snapshot.contactBadges)
                }
            }
        } else {
            WidgetEmptyText(text: String(localized: "EventNotes.Empty", table: "Widgets"))
                .padding()
        }
    }
}

struct EventNotesTitleBar: View {
    let eventNote: WidgetEventNote

    var body: some View {
        WidgetTitleBar {
            Text(verbatim: eventNote.event.title)
                .layoutPriority(1)
            Spacer(minLength: 0)
            if eventNote.isOngoing {
                Text(verbatim: String(localized: "UpNext.Now", table: "Widgets"))
                    .fontWeight(.regular)
            } else {
                Text("UpNext.StartsIn \(Text(eventNote.event.startDate, style: .relative))", tableName: "Widgets")
                    .fontWeight(.regular)
            }
        }
    }
}

struct EventNotesMediumView: View {
    private static let itemLimit = 2

    let eventNote: WidgetEventNote
    let badges: [String: ContactBadge]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(eventNote.digest.openItems.prefix(Self.itemLimit)) { item in
                EventNotesChecklistRow(item: item)
            }
            if !eventNote.digest.summary.isEmpty {
                Text(verbatim: eventNote.digest.summary)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
            EventNotesFooter(eventNote: eventNote, badges: badges)
        }
    }
}

struct EventNotesLargeView: View {
    let eventNote: WidgetEventNote
    let badges: [String: ContactBadge]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            WidgetEventTimeText(event: eventNote.event)
                .font(.caption.weight(.semibold))
                .foregroundStyle(eventNote.event.color.color)
            Text(verbatim: eventNote.digest.title)
                .font(.headline)
                .lineLimit(1)
            if !eventNote.digest.summary.isEmpty {
                Text(verbatim: eventNote.digest.summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }
            if !eventNote.digest.checklist.isEmpty {
                Divider()
                ForEach(eventNote.digest.checklist) { item in
                    EventNotesChecklistRow(item: item)
                }
            }
            Spacer(minLength: 0)
            if let responses {
                Text(verbatim: responses)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            EventNotesFooter(eventNote: eventNote, badges: badges)
        }
    }

    private var responses: String? {
        let attendees = eventNote.event.visibleAttendees
        guard !attendees.isEmpty else { return nil }
        let going = attendees.filter { $0.status.response == .accepted }.count
        return String(
            format: String(localized: "EventNotes.Responses %lld %lld", table: "Widgets"),
            going,
            attendees.count - going
        )
    }
}
