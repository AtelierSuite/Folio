import Planner
import SwiftUI

extension CalendarTimelineContainer {
    var dragHandling: TimelineDropHandlingModifier {
        TimelineDropHandlingModifier(
            drag: drag,
            dropHandler: dropHandler,
            isPinching: zoom.isPinching,
            snapMinutes: snapMinutes,
            onLift: liftSource,
            onDrop: { session in await drop(session) },
            onEdgeHold: pageAtEdge
        )
    }

    private func pageAtEdge(toward direction: CalendarPageDirection) {
        if case .workday = strip.unit {
            let page = strip.pageStart(containing: navigation.selectedDate)
            navigation.show(strip.page(page, movedBy: direction.sign))
        } else {
            navigation.page(by: pageStep, toward: direction)
        }
    }

    private func liftSource(for entry: TimelineEntry) {
        dragSource = eventsByEntryIdentifier[entry.id].map(CalendarDragSource.event)
            ?? remindersByEntryIdentifier[entry.id].map(CalendarDragSource.reminder)
    }

    private func drop(_ session: TimelineDragSession) async {
        if let source = dragSource, let proposal = session.proposal {
            dropHandler.spanDialogAnchor = CGRect(origin: drag.globalPointer, size: .zero)
            await dropHandler.move(
                source, to: savedInterval(for: source, droppedOn: proposal), hasDueTime: true,
                store: store, undoCoordinator: undoCoordinator
            )
            await load()
        }
        dragSource = nil
        drag.finish()
    }

    /// Events on a Flex Time day are drawn later than they are saved.
    private func savedInterval(for source: CalendarDragSource, droppedOn interval: DateInterval) -> DateInterval {
        guard case .event = source else { return interval }
        return store.flexTimeSchedule.scheduledInterval(displayedAs: interval)
    }
}

/// Haptics, edge paging and the drop for a timeline drag.
struct TimelineDropHandlingModifier: ViewModifier {
    let drag: TimelineDragController
    let dropHandler: CalendarDropHandler
    let isPinching: Bool
    let snapMinutes: Int
    let onLift: (TimelineEntry) -> Void
    let onDrop: (TimelineDragSession) async -> Void
    let onEdgeHold: (CalendarPageDirection) -> Void

    func body(content: Content) -> some View {
        content
            .sensoryFeedback(trigger: drag.session?.proposedHour) { oldHour, newHour in
                guard newHour != nil else { return nil }
                return oldHour == nil ? .impact(weight: .medium) : .impact(weight: .light)
            }
            .onChange(of: drag.session?.entry.id) { _, identifier in
                if identifier != nil, let entry = drag.session?.entry { onLift(entry) }
            }
            .onChange(of: drag.session?.isDropping) { _, isDropping in
                guard isDropping == true, let session = drag.session else { return }
                Task { await onDrop(session) }
            }
            .task(id: drag.edgeDirection) {
                guard let direction = drag.edgeDirection else { return }
                var delay = drag.edgePaging.holdDuration
                while !Task.isCancelled {
                    try? await Task.sleep(for: delay)
                    guard !Task.isCancelled, drag.edgeDirection == direction else { return }
                    onEdgeHold(direction)
                    delay = drag.edgePaging.repeatInterval
                }
            }
            .onChange(of: isPinching, initial: true) { _, isPinching in
                drag.isSuspended = isPinching
            }
            .onChange(of: snapMinutes, initial: true) { _, minutes in
                drag.snap = TimelineDragSnap(rawValue: minutes) ?? .default
            }
            .calendarDropDialogs(dropHandler)
    }
}
