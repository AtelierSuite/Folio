import SwiftUI

struct WatchDayPagerToolbar: ToolbarContent {
    @Binding var firstDay: Date
    let step: Int

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            Button {
                move(by: -step)
            } label: {
                Label(String(localized: "Pager.Previous", table: "Watch"), systemImage: "chevron.backward")
            }
            Button {
                firstDay = Calendar.current.startOfDay(for: .now)
            } label: {
                Label(String(localized: "Pager.Today", table: "Watch"), systemImage: "calendar")
            }
            .disabled(Calendar.current.isDateInToday(firstDay))
            Button {
                move(by: step)
            } label: {
                Label(String(localized: "Pager.Next", table: "Watch"), systemImage: "chevron.forward")
            }
        }
    }

    private func move(by days: Int) {
        firstDay = Calendar.current.date(byAdding: .day, value: days, to: firstDay) ?? firstDay
    }
}
