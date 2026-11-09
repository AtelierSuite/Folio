import SwiftUI

struct WatchAgendaDayHeader: View {
    let date: Date

    var body: some View {
        Text(title)
    }

    private var title: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return String(localized: "Timeline.Today", table: "Watch")
        }
        if calendar.isDateInTomorrow(date) {
            return String(localized: "Timeline.Tomorrow", table: "Watch")
        }
        return date.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
    }
}
