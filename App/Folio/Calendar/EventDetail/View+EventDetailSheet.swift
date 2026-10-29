import Planner
import SwiftUI

extension View {
    func eventDetailSheet(item: Binding<CalendarEvent?>) -> some View {
        sheet(item: item) { event in
            EventDetailView(event: event)
        }
    }
}
