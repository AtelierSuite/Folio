import Planner
import SwiftUI

struct SleepSettingsSection: View {
    @Environment(\.platformCapabilities) private var capabilities
    @Environment(SleepStore.self) private var store

    var body: some View {
        if capabilities.supports(.sleep) && store.isAvailable {
            Section {
                SleepTimelineToggle()
                if store.isShownOnTimeline {
                    SleepSummaryRows()
                }
            } header: {
                Text(String(localized: "Settings.Header", table: "Sleep"))
            } footer: {
                Text(String(localized: "Settings.Footer", table: "Sleep"))
            }
        }
    }
}
