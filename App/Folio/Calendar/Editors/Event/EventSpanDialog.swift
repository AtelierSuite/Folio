import Planner
import SwiftUI

enum EventSpanAction {
    case save
    case delete

    func title(for span: EventEditSpan) -> String {
        switch (self, span) {
        case (.save, .thisEvent): String(localized: "Span.Save.ThisEvent", table: "EventEditor")
        case (.save, .futureEvents): String(localized: "Span.Save.FutureEvents", table: "EventEditor")
        case (.save, .allEvents): String(localized: "Span.Save.AllEvents", table: "EventEditor")
        case (.delete, .thisEvent): String(localized: "Span.Delete.ThisEvent", table: "EventEditor")
        case (.delete, .futureEvents): String(localized: "Span.Delete.FutureEvents", table: "EventEditor")
        case (.delete, .allEvents): String(localized: "Span.Delete.AllEvents", table: "EventEditor")
        }
    }

    var message: String {
        switch self {
        case .save: String(localized: "Span.Save.Message", table: "EventEditor")
        case .delete: String(localized: "Span.Delete.Message", table: "EventEditor")
        }
    }
}

extension View {
    func eventSpanDialog(
        isPresented: Binding<Bool>,
        action: EventSpanAction,
        spans: [EventEditSpan],
        perform: @escaping (EventEditSpan) -> Void
    ) -> some View {
        confirmationDialog(action.message, isPresented: isPresented, titleVisibility: .visible) {
            ForEach(spans, id: \.self) { span in
                Button(action.title(for: span), role: action == .delete ? .destructive : nil) {
                    perform(span)
                }
            }
            Button(String(localized: "Cancel", table: "EventEditor"), role: .cancel) {}
        }
    }
}
