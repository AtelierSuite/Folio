import Planner
import SwiftUI

struct SleepSettingsSection: View {
    @Environment(\.platformCapabilities) private var capabilities
    @Environment(SleepStore.self) private var store
    let summary: SleepSummary?

    var body: some View {
        if capabilities.supports(.sleep) && store.isAvailable {
            Section {
                SleepTimelineToggle()
                if store.isShownOnTimeline, let summary {
                    SleepSummaryRows(summary: summary)
                }
            } header: {
                Text(String(localized: "Settings.Header", table: "Sleep"))
            }
        }
    }
}
