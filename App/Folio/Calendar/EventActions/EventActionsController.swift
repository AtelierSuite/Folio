import Observation
import Planner
import SwiftUI

/// What the quick actions are currently showing for one calendar screen.
@MainActor
@Observable
final class EventActionsController {
    var detailEvent: CalendarEvent?
    var editorRequest: EventEditorRequest?
    var pendingDelete: CalendarEvent?
    var pendingMove: EventMoveRequest?
    var respondingEvent: CalendarEvent?
    var menuRequest: EventMenuRequest?
    /// Asks the card showing this event to open its menu, for gestures that don't know the
    /// card's position, such as a long press that lifted a card for dragging and let go in place.
    var cardMenuEventID: String?
    var selectedEventID: String?
    /// Where each event's card is in `EventActions.coordinateSpace`, to open dialogs about it there.
    @ObservationIgnored var cardFrames: [String: CGRect] = [:]
    /// Lets a screen ignore the tap that ends another gesture, such as a drag. Kept out of
    /// `EventActions` because a new closure on every update makes every card update with it.
    @ObservationIgnored var ignoresTaps: () -> Bool = { false }
    var errorMessage: String?
}

struct EventEditorRequest: Identifiable {
    let id = UUID()
    /// `nil` for a duplicate, which is saved as a new event.
    let event: CalendarEvent?
    let draft: EventDraft
}

struct EventMoveRequest {
    let event: CalendarEvent
    let draft: EventDraft
}

struct EventMenuRequest: Equatable {
    let id = UUID()
    let event: CalendarEvent
    let point: CGPoint
}
