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
    var menuRequest: EventMenuRequest?
    var selectedEventID: String?
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
