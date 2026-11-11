import Planner
import SwiftUI

struct FlexTimeButton: View {
    @Environment(FlexTimeCenter.self) private var flexTime

    var body: some View {
        Button(
            String(localized: "Title", table: "FlexTime"),
            systemImage: flexTime.todayDelay > 0 ? "clock.badge.checkmark" : "clock.arrow.circlepath"
        ) {
            Task { await flexTime.presentForToday() }
        }
        .accessibilityIdentifier("FlexTimeButton")
    }
}
