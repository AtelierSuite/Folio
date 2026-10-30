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
    let countdowns: EventCountdownManager
    let capabilities: PlatformCapabilities
    let openURL: OpenURLAction
    let tapBehavior: EventTapBehavior
    let usesPointerSelection: Bool
    let eventsByIdentifier: [String: CalendarEvent]

    func event(for entry: TimelineEntry) -> CalendarEvent? {
        guard entry.kind == .event else { return nil }
        return eventsByIdentifier[entry.id]
    }

    func sections(for event: CalendarEvent) -> [[EventMenuItem]] {
        let canRespond = capabilities.supports(.invitationResponses) || CalendarAppLink.url(for: event) != nil
        let supportsCountdowns = capabilities.supports(.liveActivityCountdown)
        return EventMenu.sections(for: event, context: EventMenuContext(
            eventCalendar: store.calendar(withIdentifier: event.calendarIdentifier),
            writableCalendars: store.writableEventCalendars,
            hasLinkedNote: library.linkedNote(for: event) != nil,
            canStartCountdown: supportsCountdowns && countdowns.availability(for: event).state != nil,
            isCountingDown: supportsCountdowns && countdowns.isCountingDown(event),
            canRespondToInvitations: canRespond
        ))
    }

    func isSelected(_ event: CalendarEvent) -> Bool {
        controller.selectedEventID == event.id
    }

    func handle(_ gesture: EventTapGesture, on event: CalendarEvent, at point: CGPoint) {
        guard !controller.ignoresTaps() else { return }
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

    /// The point the event's menu opened at, or else its card.
    func dialogAnchor(for event: CalendarEvent) -> CGRect? {
        if let request = controller.menuRequest, request.event.id == event.id {
            return CGRect(origin: request.point, size: .zero)
        }
        return controller.cardFrames[event.id]
    }

    func presentMenuAtCard(for entry: TimelineEntry) {
        guard let event = event(for: entry) else { return }
        controller.selectedEventID = event.id
        controller.cardMenuEventID = event.id
    }
}
