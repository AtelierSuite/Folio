import Planner
import SwiftUI

struct DragSettingsSection: View {
    @AppStorage(DragSettings.snapMinutesKey) private var snapMinutes = DragSettings.defaultSnapMinutes

    var body: some View {
        Section {
            Picker(String(localized: "Settings.SnapTo", table: "Drag"), selection: $snapMinutes) {
                ForEach(TimelineDragSnap.allCases, id: \.self) { snap in
                    Text(snap.title).tag(snap.minutes)
                }
            }
            .accessibilityIdentifier("DragSnapPicker")
        } header: {
            Text(String(localized: "Settings.Header", table: "Drag"))
        } footer: {
            Text(String(localized: "Settings.SnapTo.Footer", table: "Drag"))
        }
    }
}

extension TimelineDragSnap {
    var title: String {
        switch self {
        case .fiveMinutes: String(localized: "Settings.SnapTo.FiveMinutes", table: "Drag")
        case .fifteenMinutes: String(localized: "Settings.SnapTo.FifteenMinutes", table: "Drag")
        }
    }
}
