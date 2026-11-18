import Planner
import SwiftUI

struct SleepSummaryRows: View {
    @Environment(PermissionCenter.self) private var permissionCenter
    let summary: SleepSummary

    var body: some View {
        if summary.sources.count > 1 {
            SleepSourcePicker(sources: summary.sources)
        }
        if summary.sources.isEmpty {
            SleepEmptyStateView(status: permissionCenter.status(of: .health) ?? .unknown)
        }
    }
}
