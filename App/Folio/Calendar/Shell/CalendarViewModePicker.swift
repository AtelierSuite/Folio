import SwiftUI

struct CalendarViewModePicker: View {
    @Binding var mode: CalendarViewMode

    var body: some View {
        Picker(String(localized: "Toolbar.ViewMode", table: "Calendar"), selection: $mode) {
            ForEach(CalendarViewMode.allCases) { mode in
                Label(mode.title, systemImage: mode.systemImage)
                    .tag(mode)
            }
        }
    }
}
