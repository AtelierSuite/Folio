import Planner
import SwiftUI

extension View {
    /// A tap on the empty grid clears the selected event; a double tap asks to add an event or
    /// reminder in the slot tapped.
    func timelineCreationTap(days: TimelineDays, hourHeight: CGFloat) -> some View {
        modifier(TimelineCreationTapModifier(days: days, hourHeight: hourHeight))
    }
}

private struct TimelineCreationTapModifier: ViewModifier {
    @Environment(\.calendarCreation) private var creation
    @Environment(\.eventActions) private var eventActions
    @AppStorage(DragSettings.snapMinutesKey) private var snapMinutes = DragSettings.defaultSnapMinutes
    let days: TimelineDays
    let hourHeight: CGFloat
    @State private var frame: CGRect = .zero

    func body(content: Content) -> some View {
        content
            .contentShape(.rect)
            .onGeometryChange(for: CGRect.self) {
                $0.frame(in: CalendarCreationAction.coordinateSpace)
            } action: { frame = $0 }
            .gesture(
                SpatialTapGesture(count: 2, coordinateSpace: CalendarCreationAction.coordinateSpace)
                    .exclusively(before: TapGesture())
                    .onEnded(handle),
                isEnabled: creation != nil || eventActions != nil
            )
    }

    private func handle(_ value: ExclusiveGesture<SpatialTapGesture, TapGesture>.Value) {
        switch value {
        case .first(let doubleTap):
            handleDoubleTap(at: doubleTap.location)
        case .second:
            eventActions?.clearSelection()
        }
    }

    private func handleDoubleTap(at point: CGPoint) {
        guard let creation, frame.width > 0, hourHeight > 0 else { return }
        let dayWidth = frame.width / CGFloat(max(days.count, 1))
        let dayIndex = Int(((point.x - frame.minX) / dayWidth).rounded(.down))
        let hour = Double((point.y - frame.minY) / hourHeight)
        let snap = TimelineDragSnap(rawValue: snapMinutes) ?? .default
        guard let date = days.startOfSlot(onDay: dayIndex, atHour: hour, snap: snap) else { return }
        creation(CalendarCreationSlot(date: date, hasTime: true), at: point)
    }
}
