import Planner
import SwiftUI

struct FlexTimeButton: View {
    @Environment(FlexTimeCenter.self) private var flexTime

    var body: some View {
        Button {
            Task { await flexTime.presentForToday() }
        } label: {
            if flexTime.todayDelay > 0 {
                Label(String(localized: "Title", table: "FlexTime"), systemImage: "clock.badge.checkmark")
            } else {
                Label(String(localized: "Title", table: "FlexTime"), image: .flextime)
            }
        }
        .accessibilityIdentifier("FlexTimeButton")
    }
}
