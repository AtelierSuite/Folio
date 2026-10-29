import Planner
import SwiftUI

extension View {
    /// Writable month chips can be dragged to another day; read-only ones and invitations can't.
    @ViewBuilder
    func calendarMonthDraggable(_ entry: TimelineEntry, from day: Date) -> some View {
        if entry.isReadOnly {
            self
        } else {
            draggable(CalendarItemDragPayload(entryIdentifier: entry.id, sourceDay: day).string)
        }
    }

    func calendarMonthDropDestination(
        isTargeted: Binding<Bool>,
        onDrop: @escaping (CalendarItemDragPayload) -> Bool
    ) -> some View {
        dropDestination(for: String.self) { strings, _ in
            guard let payload = strings.lazy.compactMap(CalendarItemDragPayload.init).first else { return false }
            return onDrop(payload)
        } isTargeted: { isTargeted.wrappedValue = $0 }
    }
}
