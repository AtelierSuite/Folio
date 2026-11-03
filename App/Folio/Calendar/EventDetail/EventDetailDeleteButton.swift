import Planner
import SwiftUI

struct EventDetailDeleteButton: View {
    let event: CalendarEvent
    let onDelete: (EventEditSpan) -> Void
    @State private var isConfirmingDelete = false

    var body: some View {
        Button(String(localized: "Detail.Delete", table: "EventEditor"), role: .destructive) {
            if event.isRecurring {
                isConfirmingDelete = true
            } else {
                onDelete(.thisEvent)
            }
        }
        .eventSpanDialog(isPresented: $isConfirmingDelete, action: .delete, spans: spans) { span in
            onDelete(span)
        }
    }

    private var spans: [EventEditSpan] {
        event.isRecurring ? EventEditSpan.allCases : [.thisEvent]
    }
}
