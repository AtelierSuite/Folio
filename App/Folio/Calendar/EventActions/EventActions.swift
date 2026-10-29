import Planner
import SwiftUI

/// Runs the quick actions for the events on one calendar screen. Hosts build it with
/// `eventActionsHost(events:)` and cards read it from `\.eventActions`.
@MainActor
struct EventActions {
    static let coordinateSpace = NamedCoordinateSpace.named("EventActions")

    let controller: EventActionsController
    let store: CalendarStore
    let undoCoordinator: UndoCoordinator
    let library: NotesLibrary
    let router: AppRouter
    let openURL: OpenURLAction
    let tapBehavior: EventTapBehavior
    let usesPointerSelection: Bool
    let eventsByIdentifier: [String: CalendarEvent]

    func event(for entry: TimelineEntry) -> CalendarEvent? {
        guard entry.kind == .event else { return nil }
        return eventsByIdentifier[entry.id]
    }

    func sections(for event: CalendarEvent) -> [[EventMenuItem]] {
        // Start Countdown (#30) and Respond… (#15) switch on here once those features land.
        EventMenu.sections(for: event, context: EventMenuContext(
            eventCalendar: store.calendar(withIdentifier: event.calendarIdentifier),
            writableCalendars: store.writableEventCalendars,
            hasLinkedNote: library.linkedNote(for: event) != nil
        ))
    }

    func isSelected(_ event: CalendarEvent) -> Bool {
        controller.selectedEventID == event.id
    }

    func handle(_ gesture: EventTapGesture, on event: CalendarEvent, at point: CGPoint) {
        switch tapBehavior.outcome(of: gesture, usesPointerSelection: usesPointerSelection) {
        case .showDetails:
            controller.selectedEventID = event.id
            controller.detailEvent = event
        case .showMenu:
            controller.selectedEventID = event.id
            presentMenu(for: event, at: point)
        case .select:
            controller.selectedEventID = event.id
        }
    }

    func presentMenu(for event: CalendarEvent, at point: CGPoint) {
        controller.menuRequest = EventMenuRequest(event: event, point: point)
    }
}
