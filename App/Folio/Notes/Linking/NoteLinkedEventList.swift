import Planner
import SwiftUI

struct NoteLinkedEventList: View {
    let links: [NoteLink]
    let onUnlink: (NoteLink) -> Void

    var body: some View {
        ForEach(links, id: \.event.eventKey) { link in
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title(for: link))
                        .lineLimit(1)
                    Text(dayText(for: link))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Button(String(localized: "LinkEvent.Remove", table: "LinkedNotes"), systemImage: "minus.circle.fill") {
                    onUnlink(link)
                }
                .labelStyle(.iconOnly)
                .foregroundStyle(.red)
                .buttonStyle(.borderless)
            }
        }
    }

    private func title(for link: NoteLink) -> String {
        link.event.title.isEmpty ? String(localized: "LinkEvent.UntitledEvent", table: "LinkedNotes") : link.event.title
    }

    private func dayText(for link: NoteLink) -> String {
        DailyNoteNaming.date(forDayKey: link.event.dayKey)?.formatted(date: .abbreviated, time: .omitted)
            ?? link.event.dayKey
    }
}
