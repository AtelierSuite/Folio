import Planner
import SwiftUI

struct FlexTimeTodaySection: View {
    @Environment(FlexTimeCenter.self) private var flexTime

    var body: some View {
        if flexTime.todayDelay > 0 {
            Section(String(localized: "Settings.Today.Header", table: "FlexTime")) {
                Text(String(
                    localized: "Settings.Today.Delay \(FlexTimeFormatting.duration(flexTime.todayDelay))",
                    table: "FlexTime"
                ))
                Button(String(localized: "Settings.Today.TurnOff", table: "FlexTime"), role: .destructive) {
                    Task { await flexTime.turnOff() }
                }
                .accessibilityIdentifier("FlexTimeTurnOffButton")
            }
        }
    }
}
