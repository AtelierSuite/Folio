import SwiftUI

struct CalendarViewCommands: Commands {
    @AppStorage("Calendar.ViewMode") private var mode: CalendarViewMode = .day
    @AppStorage("Calendar.MultiDayCount") private var dayCount: MultiDayCount = .three

    var body: some Commands {
        CommandGroup(before: .toolbar) {
            Section {
                CalendarViewModePicker(mode: $mode)
                    .pickerStyle(.inline)
            }
            if mode == .multiDay {
                Section {
                    MultiDayCountPicker(dayCount: $dayCount)
                        .pickerStyle(.inline)
                }
            }
        }
    }
}
