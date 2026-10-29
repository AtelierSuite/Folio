import Planner
import SwiftUI

extension View {
    func calendarItemSheet(request: Binding<CalendarItemRequest?>) -> some View {
        modifier(CalendarItemSheet(request: request))
    }
}

private struct CalendarItemSheet: ViewModifier {
    @Environment(CalendarStore.self) private var store
    @Binding var request: CalendarItemRequest?
    @State private var presentedItem: CalendarPresentedItem?

    func body(content: Content) -> some View {
        content
            .task(id: request) {
                guard let request else { return }
                presentedItem = await resolve(request)
                self.request = nil
            }
            .sheet(item: $presentedItem) { item in
                switch item {
                case .event(let event): EventDetailView(event: event)
                case .reminder(let reminder): ReminderEditorView(reminder: reminder)
                }
            }
    }

    private func resolve(_ request: CalendarItemRequest) async -> CalendarPresentedItem? {
        if let event = await store.event(matching: request.reference, near: request.date) {
            return .event(event)
        }
        return await store.reminder(matching: request.reference).map(CalendarPresentedItem.reminder)
    }
}
