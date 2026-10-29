import Planner
import SwiftUI

struct SleepSummaryRows: View {
    @Environment(SleepStore.self) private var store
    @Environment(PermissionCenter.self) private var permissionCenter
    @State private var lastNight: SleepSession?
    @State private var sources: [SleepSource] = []
    @State private var hasLoaded = false

    var body: some View {
        Group {
            if let lastNight {
                LabeledContent(
                    String(localized: "Settings.LastNight", table: "Sleep"),
                    value: Duration.seconds(lastNight.asleepDuration).formatted(.units(allowed: [.hours, .minutes]))
                )
                .accessibilityIdentifier("SleepLastNight")
            }
            if sources.count > 1 {
                SleepSourcePicker(sources: sources)
            }
            if hasLoaded && sources.isEmpty {
                SleepEmptyStateView(status: permissionCenter.status(of: .health) ?? .unknown)
            }
        }
        .task(id: store.revision) {
            lastNight = await store.lastNight()
            sources = await store.recentSources()
            hasLoaded = true
        }
    }
}
