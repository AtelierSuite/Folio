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
                    Rectangle()
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
            .onGeometryChange(for: CGRect.self) { $0.frame(in: EventActions.coordinateSpace) } action: { newFrame in
                frame = newFrame
                actions.controller.cardFrames[event.id] = newFrame
            }
            .onDisappear {
                if actions.controller.cardFrames[event.id] == frame {
                    actions.controller.cardFrames[event.id] = nil
                }
            }
            .onChange(of: actions.controller.cardMenuEventID) { _, eventID in
                guard eventID == event.id else { return }
                actions.controller.cardMenuEventID = nil
                actions.presentMenu(for: event, at: center)
            }
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
