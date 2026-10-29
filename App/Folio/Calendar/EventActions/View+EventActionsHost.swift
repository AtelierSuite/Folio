import Planner
import SwiftUI

extension View {
    /// Gives the cards inside quick actions for `events`, and presents what they open:
    /// details, the editor, span and error dialogs and the menu a tap opens.
    func eventActionsHost(
        events: [CalendarEvent],
        controller: EventActionsController? = nil,
        ignoresTaps: @escaping () -> Bool = { false }
    ) -> some View {
        modifier(EventActionsHostModifier(events: events, externalController: controller, ignoresTaps: ignoresTaps))
    }
}

private struct EventActionsHostModifier: ViewModifier {
    @Environment(CalendarStore.self) private var store
    @Environment(UndoCoordinator.self) private var undoCoordinator
    @Environment(NotesLibrary.self) private var library
    @Environment(AppRouter.self) private var router
    @Environment(EventCountdownManager.self) private var countdowns
    @Environment(\.openURL) private var openURL
    @Environment(\.platformCapabilities) private var capabilities
    @AppStorage(EventTapSettings.behaviorKey, store: AppGroup.userDefaults)
    private var tapBehavior = EventTapSettings.defaultBehavior
    @State private var ownController = EventActionsController()
    let events: [CalendarEvent]
    let externalController: EventActionsController?
    let ignoresTaps: () -> Bool

    private var controller: EventActionsController {
        externalController ?? ownController
    }

    private var actions: EventActions {
        EventActions(
            controller: controller,
            store: store,
            undoCoordinator: undoCoordinator,
            library: library,
            router: router,
            countdowns: countdowns,
            capabilities: capabilities,
            openURL: openURL,
            tapBehavior: tapBehavior,
            usesPointerSelection: capabilities.usesPointerSelection,
            eventsByIdentifier: Dictionary(events.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first }),
            ignoresTaps: ignoresTaps
        )
    }

    func body(content: Content) -> some View {
        @Bindable var controller = controller
        let actions = actions
        content
            .environment(\.eventActions, actions)
            .overlay {
                EventMenuPresenter(request: controller.menuRequest, actions: actions)
                    .allowsHitTesting(false)
            }
            .coordinateSpace(EventActions.coordinateSpace)
            .eventDetailSheet(item: $controller.detailEvent)
            .sheet(item: $controller.editorRequest) { request in
                if let event = request.event {
                    EventEditorView(event: event, draft: request.draft) { _, _ in }
                } else {
                    EventEditorView(newDraft: request.draft)
                }
            }
            .eventSpanDialog(
                isPresented: isPresented($controller.pendingDelete),
                action: .delete,
                spans: EventEditSpan.allCases
            ) { span in
                if let event = controller.pendingDelete {
                    actions.delete(event, span: span)
                }
            }
            .eventSpanDialog(
                isPresented: isPresented($controller.pendingMove),
                action: .save,
                spans: [.futureEvents, .allEvents]
            ) { span in
                if let request = controller.pendingMove {
                    actions.finishMove(request, span: span)
                }
            }
            .alert(
                String(localized: "Error.Title", table: "EventActions"),
                isPresented: isPresented($controller.errorMessage)
            ) {
                Button(String(localized: "OK", table: "EventEditor"), role: .cancel) {}
            } message: {
                Text(controller.errorMessage ?? "")
            }
    }

    private func isPresented<Value>(_ value: Binding<Value?>) -> Binding<Bool> {
        Binding(get: { value.wrappedValue != nil }, set: { if !$0 { value.wrappedValue = nil } })
    }
}
