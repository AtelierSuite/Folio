import SwiftUI

extension EnvironmentValues {
    @Entry var eventActions: EventActions?
    /// Set where a long press on a card lifts it to drag, so touch screens skip the context menu
    /// and the drag shows the menu with `presentMenuAtCard(for:)` when the card is let go in place.
    @Entry var eventCardsLiftToDrag = false
}
