import SwiftUI

struct CalendarMonthView: View {
    var body: some View {
        ContentUnavailableView(CalendarViewMode.month.title, systemImage: "calendar")
    }
}
