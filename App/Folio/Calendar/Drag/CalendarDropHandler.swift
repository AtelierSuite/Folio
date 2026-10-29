import Observation
import Planner
import SwiftUI

/// Saves a dropped item through the undo coordinator, so every drop shows the undo toast,
/// and asks which occurrences to move for a recurring event.
@MainActor
@Observable
final class CalendarDropHandler {
    var isChoosingSpan = false
    var errorMessage: String?
    @ObservationIgnored private var spanContinuation: CheckedContinuation<EventEditSpan?, Never>?

    static let recurringSpans: [EventEditSpan] = [.thisEvent, .futureEvents]

    func move(
        _ source: CalendarDragSource,
        to interval: DateInterval,
        hasDueTime: Bool,
        store: CalendarStore,
        undoCoordinator: UndoCoordinator
    ) async {
        do {
            switch source {
            case .event(let event):
                guard let span = await span(for: event) else { return }
                let draft = try await store.eventDraft(for: event).moved(to: interval)
                try await undoCoordinator.updateEvent(event, with: draft, span: span, action: .move(.event))
            case .reminder(let reminder):
                let draft = ReminderDraft(reminder).rescheduled(to: interval.start, hasDueTime: hasDueTime)
                try await undoCoordinator.updateReminder(reminder, with: draft, action: .move(.reminder))
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func chooseSpan(_ span: EventEditSpan?) {
        spanContinuation?.resume(returning: span)
        spanContinuation = nil
    }

    /// The dialog's binding turns false before or after its button runs, so dismissing waits a turn
    /// to let a chosen span win over a cancel.
    func spanDialogDismissed() {
        Task { @MainActor in chooseSpan(nil) }
    }

    private func span(for event: CalendarEvent) async -> EventEditSpan? {
        guard event.isRecurring else { return .thisEvent }
        chooseSpan(nil)
        return await withCheckedContinuation { continuation in
            spanContinuation = continuation
            isChoosingSpan = true
        }
    }
}

extension View {
    func calendarDropDialogs(_ handler: CalendarDropHandler) -> some View {
        eventSpanDialog(
            isPresented: Binding(
                get: { handler.isChoosingSpan },
                set: { isPresented in
                    handler.isChoosingSpan = isPresented
                    if !isPresented { handler.spanDialogDismissed() }
                }
            ),
            action: .save,
            spans: CalendarDropHandler.recurringSpans
        ) { span in
            handler.chooseSpan(span)
        }
        .alert(
            String(localized: "Drop.Failed", table: "Drag"),
            isPresented: Binding(
                get: { handler.errorMessage != nil },
                set: { if !$0 { handler.errorMessage = nil } }
            )
        ) {
            Button(String(localized: "OK", table: "Drag"), role: .cancel) {}
        } message: {
            Text(handler.errorMessage ?? "")
        }
    }
}
