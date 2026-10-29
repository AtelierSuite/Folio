import Planner
import SwiftUI

/// Search still finds notes without calendar access, so it only shows a banner instead of a permission gate.
struct SearchPermissionBanner: View {
    @Environment(PermissionCenter.self) private var center
    @State private var dismissedKinds: Set<PermissionKind> = []

    private var missingKind: PermissionKind? {
        [PermissionKind.calendar, .reminders].first { kind in
            guard let status = center.status(of: kind), status != .unavailable else { return false }
            return !status.allowsAccess && !dismissedKinds.contains(kind)
        }
    }

    var body: some View {
        if let missingKind {
            PermissionBanner(kind: missingKind) {
                dismissedKinds.insert(missingKind)
            }
        }
    }
}
