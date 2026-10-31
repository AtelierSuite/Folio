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
    /// Built once per events array: cards compare `EventActions` on every update, and a rebuilt
    /// dictionary is compared entry by entry, while the same one is compared by identity.
    @State private var eventsByIdentifier: [String: CalendarEvent] = [:]
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
            eventsByIdentifier: eventsByIdentifier
        )
    }

    func body(content: Content) -> some View {
        @Bindable var controller = controller
        let actions = actions
        content
            .environment(\.eventActions, actions)
            .onChange(of: events, initial: true, updateLookup)
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
            .eventResponseSheet(event: $controller.respondingEvent)
            .dialogAnchor(at: spanDialogAnchor(actions), in: EventActions.coordinateSpace) { anchor in
                anchor
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

    private func updateLookup() {
        eventsByIdentifier = Dictionary(events.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        controller.ignoresTaps = ignoresTaps
    }

    private func spanDialogAnchor(_ actions: EventActions) -> CGRect? {
        (controller.pendingDelete ?? controller.pendingMove?.event).flatMap(actions.dialogAnchor(for:))
    }

    private func isPresented<Value>(_ value: Binding<Value?>) -> Binding<Bool> {
        Binding(get: { value.wrappedValue != nil }, set: { if !$0 { value.wrappedValue = nil } })
    }
}
