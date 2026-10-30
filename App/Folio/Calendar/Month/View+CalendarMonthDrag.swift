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

    /// `onDrop` gets the day's frame in global coordinates, to ask about the drop from there.
    func calendarMonthDropDestination(
        isTargeted: Binding<Bool>,
        onDrop: @escaping (CalendarItemDragPayload, CGRect) -> Bool
    ) -> some View {
        modifier(CalendarMonthDropDestinationModifier(isTargeted: isTargeted, onDrop: onDrop))
    }
}

private struct CalendarMonthDropDestinationModifier: ViewModifier {
    @Binding var isTargeted: Bool
    let onDrop: (CalendarItemDragPayload, CGRect) -> Bool
    @State private var frame: CGRect = .zero

    func body(content: Content) -> some View {
        content
            .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { frame = $0 }
            .dropDestination(for: String.self) { strings, _ in
                guard let payload = strings.lazy.compactMap(CalendarItemDragPayload.init).first else { return false }
                return onDrop(payload, frame)
            } isTargeted: { isTargeted = $0 }
    }
}
