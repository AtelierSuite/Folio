import Planner
import SwiftUI

struct SearchResultRow: View {
    let document: SearchDocument
    let queryText: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Image(systemName: iconName)
                .foregroundStyle(document.color?.color ?? .accentColor)
                .frame(width: 22)
                .accessibilityLabel(document.kind.title)
            VStack(alignment: .leading, spacing: 2) {
                Text(document.title.isEmpty ? String(localized: "Result.Untitled", table: "Search") : document.title)
                    .strikethrough(document.isCompleted)
                    .foregroundStyle(document.isCompleted ? .secondary : .primary)
                    .lineLimit(2)
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                if let snippet = document.snippet(matching: queryText) {
                    Text(snippet)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            Spacer(minLength: 0)
            if document.hasMeetingLink {
                Image(systemName: "video")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .accessibilityLabel(String(localized: "Filter.MeetingLink", table: "Search"))
            }
        }
        .contentShape(.rect)
    }

    private var iconName: String {
        switch document.kind {
        case .event: "calendar"
        case .reminder: document.isCompleted ? "checkmark.circle.fill" : "circle"
        case .note: "note.text"
        }
    }

    private var subtitle: String? {
        let parts = [timeDescription, document.detail].compactMap { $0 }.filter { !$0.isEmpty }
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }

    private var timeDescription: String? {
        guard let date = document.date else { return nil }
        switch document.kind {
        case .event:
            if document.isAllDay {
                return String(localized: "Result.AllDay", table: "Search")
            }
            return (date..<(document.endDate ?? date)).formatted(.interval.hour().minute())
        case .reminder:
            return document.isAllDay ? nil : date.formatted(.dateTime.hour().minute())
        case .note:
            return nil
        }
    }
}
