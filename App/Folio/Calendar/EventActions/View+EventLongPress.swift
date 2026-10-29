import Planner
import SwiftUI

/// A context menu with a preview, unless a long press already means something else here.
/// Month chips sit in a paging scroll view where `.contextMenu` doesn't open on a long press, so
/// on touch screens they open the menu at the chip instead. Where cards lift to drag, the drag
/// opens the menu when a card is let go in place.
struct EventLongPressModifier: ViewModifier {
    @Environment(\.eventCardsLiftToDrag) private var cardsLiftToDrag
    let event: CalendarEvent
    let actions: EventActions
    let opensMenuAtCard: Bool
    let center: () -> CGPoint

    func body(content: Content) -> some View {
        if actions.usesPointerSelection {
            content.eventContextMenu(event, actions: actions)
        } else if cardsLiftToDrag {
            content
        } else if opensMenuAtCard {
            content.onLongPressGesture {
                actions.controller.selectedEventID = event.id
                actions.presentMenu(for: event, at: center())
            }
        } else {
            content.eventContextMenu(event, actions: actions)
        }
    }
}
