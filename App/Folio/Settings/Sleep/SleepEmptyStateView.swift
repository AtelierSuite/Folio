import Planner
import SwiftUI

/// HealthKit hides read denial, so when nothing comes back the copy can't claim access is off.
struct SleepEmptyStateView: View {
    let status: PermissionStatus

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(status.mayHideMissingAccess ? PermissionKind.health.deniedTitle : noDataTitle)
                .font(.headline)
            Text(status.mayHideMissingAccess ? PermissionKind.health.deniedDescription : noDataDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("SleepEmptyState")
    }

    private var noDataTitle: String {
        String(localized: "Empty.Title", table: "Sleep")
    }

    private var noDataDescription: String {
        String(localized: "Empty.Description", table: "Sleep")
    }
}
