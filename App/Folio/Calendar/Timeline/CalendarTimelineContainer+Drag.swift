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
            onEdgeHold: { direction in navigation.page(by: pageStep, toward: direction) }
        )
    }

    private func liftSource(for entry: TimelineEntry) {
        dragSource = eventsByEntryIdentifier[entry.id].map(CalendarDragSource.event)
            ?? remindersByEntryIdentifier[entry.id].map(CalendarDragSource.reminder)
    }

    private func drop(_ session: TimelineDragSession) async {
        if let source = dragSource, let proposal = session.proposal {
            await dropHandler.move(
                source, to: proposal, hasDueTime: true, store: store, undoCoordinator: undoCoordinator
            )
            await load()
        }
        dragSource = nil
        drag.finish()
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
            .sensoryFeedback(trigger: drag.session?.proposal) { oldProposal, newProposal in
                guard newProposal != nil else { return nil }
                return oldProposal == nil ? .impact(weight: .medium) : .selection
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
