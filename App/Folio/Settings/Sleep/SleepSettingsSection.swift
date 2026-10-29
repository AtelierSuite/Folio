import Planner
import SwiftUI

struct SleepSettingsSection: View {
    @Environment(\.platformCapabilities) private var capabilities
    @Environment(SleepStore.self) private var store
    @State private var summary: SleepSummary?

    var body: some View {
        if capabilities.supports(.sleep) && store.isAvailable {
            Section {
                SleepTimelineToggle()
                    .task(id: LoadKey(revision: store.revision, isShown: store.isShownOnTimeline)) {
                        summary = store.isShownOnTimeline ? await SleepSummary(store: store) : nil
                    }
                if store.isShownOnTimeline, let summary {
                    SleepSummaryRows(summary: summary)
                }
            } header: {
                Text(String(localized: "Settings.Header", table: "Sleep"))
            } footer: {
                Text(String(localized: "Settings.Footer", table: "Sleep"))
            }
        }
    }

    private struct LoadKey: Equatable {
        let revision: Int
        let isShown: Bool
    }
}
