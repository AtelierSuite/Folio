import SwiftUI

struct MultiDayCountPicker: View {
    @Binding var dayCount: MultiDayCount

    var body: some View {
        Picker(String(localized: "DayCount.Picker", table: "Day"), selection: $dayCount) {
            ForEach(MultiDayCount.allCases) { count in
                Label(count.title, systemImage: count.systemImage)
                    .tag(count)
            }
        }
        .pickerStyle(.menu)
    }
}
