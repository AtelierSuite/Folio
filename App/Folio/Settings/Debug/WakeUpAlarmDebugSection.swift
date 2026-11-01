#if DEBUG
import Planner
import SwiftUI

struct WakeUpAlarmDebugSection: View {
    @Environment(WakeUpAlarmCenter.self) private var wakeUpAlarms

    var body: some View {
        Section(String(localized: "Debug.Section", table: "WakeUpAlarms")) {
            Button(String(localized: "Debug.RingSoon", table: "WakeUpAlarms")) {
                Task { await wakeUpAlarms.ringNextAlarmSoon() }
            }
            .disabled(wakeUpAlarms.upcomingAlarms.isEmpty)
            .accessibilityIdentifier("WakeUpAlarmRingSoon")
        }
    }
}
#endif
