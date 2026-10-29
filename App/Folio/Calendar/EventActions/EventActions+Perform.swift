import Planner
import SwiftUI

extension EventActions {
    func perform(_ item: EventMenuItem, on event: CalendarEvent) {
        switch item {
        case .showDetails, .startCountdown, .respond:
            controller.detailEvent = event
        case .joinMeeting(let link):
            openURL(link.url)
        case .getDirections(let url):
            openURL(url)
        case .copy:
            EventPasteboard.copy(EventCopyText.text(for: event))
        case .moveToCalendar:
            break
        case .edit, .duplicate, .openLinkedNote, .createLinkedNote, .delete:
            performChange(item, on: event)
        }
    }

    private func performChange(_ item: EventMenuItem, on event: CalendarEvent) {
        switch item {
        case .edit:
            run {
                let draft = try await store.eventDraft(for: event)
                controller.editorRequest = EventEditorRequest(event: event, draft: draft)
            }
        case .duplicate:
            run { try await duplicate(event) }
        case .openLinkedNote, .createLinkedNote:
            run {
                try await LinkedNoteActions(library: library, calendarStore: store, router: router)
                    .openNote(for: event)
            }
        case .delete where event.isRecurring:
            controller.pendingDelete = event
        case .delete:
            delete(event, span: .thisEvent)
        default:
            break
        }
    }

    func move(_ event: CalendarEvent, to calendar: PlannerCalendar) {
        run {
            let draft = try await store.eventDraft(for: event).moved(toCalendar: calendar.id)
            if event.isRecurring {
                controller.pendingMove = EventMoveRequest(event: event, draft: draft)
            } else {
                try await undoCoordinator.updateEvent(event, with: draft, action: .move(.event))
            }
        }
    }

    func finishMove(_ request: EventMoveRequest, span: EventEditSpan) {
        run {
            try await undoCoordinator.updateEvent(request.event, with: request.draft, span: span, action: .move(.event))
        }
    }

    func delete(_ event: CalendarEvent, span: EventEditSpan) {
        run { try await undoCoordinator.deleteEvent(event, span: span) }
    }

    private func duplicate(_ event: CalendarEvent) async throws {
        let draft = try await store.eventDraft(for: event).duplicated(
            writableCalendarIdentifiers: Set(store.writableEventCalendars.map(\.id)),
            fallbackCalendarIdentifier: store.defaultEventCalendarIdentifier
        )
        controller.editorRequest = EventEditorRequest(event: nil, draft: draft)
    }

    private func run(_ work: @escaping @MainActor () async throws -> Void) {
        let controller = controller
        Task {
            do {
                try await work()
            } catch {
                controller.errorMessage = error.localizedDescription
            }
        }
    }
}
