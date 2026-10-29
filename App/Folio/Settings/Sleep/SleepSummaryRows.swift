import Planner
import SwiftUI

struct SleepSummaryRows: View {
    @Environment(PermissionCenter.self) private var permissionCenter
    let summary: SleepSummary

    var body: some View {
        if let lastNight = summary.lastNight {
            LabeledContent(
                String(localized: "Settings.LastNight", table: "Sleep"),
                value: Duration.seconds(lastNight.asleepDuration).formatted(.units(allowed: [.hours, .minutes]))
            )
            .accessibilityIdentifier("SleepLastNight")
        }
        if summary.sources.count > 1 {
            SleepSourcePicker(sources: summary.sources)
        }
        if summary.sources.isEmpty {
            SleepEmptyStateView(status: permissionCenter.status(of: .health) ?? .unknown)
        }
    }
}
