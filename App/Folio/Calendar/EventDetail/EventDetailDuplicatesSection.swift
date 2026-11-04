import Planner
import SwiftUI

struct EventDetailDuplicatesSection: View {
    @Environment(CalendarStore.self) private var store
    let duplicates: [CalendarEvent]
    let onSelect: (CalendarEvent) -> Void

    var body: some View {
        if !duplicates.isEmpty {
            Section(String(localized: "Detail.Duplicates.Header", table: "EventEditor")) {
                ForEach(duplicates) { duplicate in
                    Button {
                        onSelect(duplicate)
                    } label: {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(duplicate.color.color)
                                .frame(width: 10, height: 10)
                            Text(store.calendar(withIdentifier: duplicate.calendarIdentifier)?.title ?? duplicate.title)
                            Spacer(minLength: 0)
                            Image(systemName: "chevron.forward")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.tertiary)
                        }
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
