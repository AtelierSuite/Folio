import Planner
import SwiftUI

/// How an event view sits in its screen.
enum EventInteractionPlacement {
    /// A card or row of its own: a tap follows the setting.
    case standalone
    /// A chip inside a month cell: in details mode a tap still opens the day, and VoiceOver
    /// reads the cell as one element, so the actions name the event.
    case monthCell
}

extension View {
    /// Tap, double-click, context menu and VoiceOver actions for an event card.
    @ViewBuilder
    func eventInteractions(
        _ event: CalendarEvent,
        actions: EventActions?,
        placement: EventInteractionPlacement = .standalone
    ) -> some View {
        if let actions {
            modifier(EventInteractionsModifier(event: event, actions: actions, placement: placement))
        } else {
            self
        }
    }
}

private struct EventInteractionsModifier: ViewModifier {
    let event: CalendarEvent
    let actions: EventActions
    let placement: EventInteractionPlacement
    @State private var frame: CGRect = .zero

    private var handlesTap: Bool {
        placement == .standalone || actions.tapBehavior == .showsQuickActions
    }

    func body(content: Content) -> some View {
        content
            .overlay {
                if actions.usesPointerSelection && actions.isSelected(event) {
                    RoundedRectangle(cornerRadius: 5)
                        .strokeBorder(Color.accentColor, lineWidth: 2)
                        .allowsHitTesting(false)
                }
            }
            .contentShape(.rect)
            .gesture(
                TapGesture(count: 2).onEnded { actions.handle(.doubleTap, on: event, at: center) },
                isEnabled: actions.usesPointerSelection
            )
            .gesture(
                SpatialTapGesture(coordinateSpace: EventActions.coordinateSpace).onEnded { value in
                    actions.handle(.tap, on: event, at: value.location)
                },
                isEnabled: handlesTap
            )
            .modifier(EventLongPressModifier(
                event: event, actions: actions, opensMenuAtCard: placement == .monthCell, center: { center }
            ))
            .onGeometryChange(for: CGRect.self) { $0.frame(in: EventActions.coordinateSpace) } action: { frame = $0 }
            .modifier(EventAccessibilityModifier(
                event: event, actions: actions, placement: placement, center: center
            ))
    }

    private var center: CGPoint {
        CGPoint(x: frame.midX, y: frame.midY)
    }
}

private struct EventAccessibilityModifier: ViewModifier {
    let event: CalendarEvent
    let actions: EventActions
    let placement: EventInteractionPlacement
    let center: CGPoint

    func body(content: Content) -> some View {
        switch placement {
        case .standalone:
            content
                .accessibilityAddTraits(.isButton)
                .accessibilityAction { actions.handle(.tap, on: event, at: center) }
                .accessibilityActions { EventMenuAccessibilityActions(event: event, actions: actions) }
        case .monthCell:
            content
                .accessibilityActions {
                    EventMenuAccessibilityActions(event: event, actions: actions, namesEvent: true)
                }
        }
    }
}

/// A context menu with a preview. Month chips sit in a paging scroll view where `.contextMenu`
/// doesn't open on a long press, so on touch screens they open the menu at the chip instead.
private struct EventLongPressModifier: ViewModifier {
    let event: CalendarEvent
    let actions: EventActions
    let opensMenuAtCard: Bool
    let center: () -> CGPoint

    func body(content: Content) -> some View {
        if opensMenuAtCard && !actions.usesPointerSelection {
            content.onLongPressGesture {
                actions.controller.selectedEventID = event.id
                actions.presentMenu(for: event, at: center())
            }
        } else {
            content.eventContextMenu(event, actions: actions)
        }
    }
}

extension View {
    func eventContextMenu(_ event: CalendarEvent, actions: EventActions) -> some View {
        #if os(iOS)
        contextMenu {
            EventMenuContent(event: event, actions: actions)
        } preview: {
            EventMenuPreview(event: event)
        }
        #else
        contextMenu {
            EventMenuContent(event: event, actions: actions)
        }
        #endif
    }
}
