import SwiftUI

struct CalendarWeekLayoutPicker: View {
    @Binding var layout: CalendarWeekLayout

    var body: some View {
        Picker(String(localized: "WeekLayout.Picker", table: "Calendar"), selection: $layout) {
            ForEach(CalendarWeekLayout.allCases) { layout in
                Label(layout.title, systemImage: layout.systemImage)
                    .tag(layout)
            }
        }
    }
}
