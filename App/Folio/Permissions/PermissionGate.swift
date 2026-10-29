import Planner
import SwiftUI

struct PermissionGate<Content: View>: View {
    @Environment(PermissionCenter.self) private var center
    @State private var dismissedBanners: Set<PermissionKind> = []
    let kinds: [PermissionKind]
    @ViewBuilder let content: Content

    var body: some View {
        switch center.gateState(for: kinds) {
        case .loading:
            Color.clear
        case .unavailable:
            content
        case .content(let missing):
            content
                .safeAreaInset(edge: .top, spacing: 0) {
                    if let banner = missing.first(where: { !dismissedBanners.contains($0) }) {
                        PermissionBanner(kind: banner) {
                            dismissedBanners.insert(banner)
                        }
                    }
                }
        case .blocked(let primary, let requestable):
            PermissionBlockedView(kind: primary, requestable: requestable)
        }
    }
}

extension View {
    func permissionGate(_ kinds: PermissionKind...) -> some View {
        PermissionGate(kinds: kinds) { self }
    }

    func calendarPermissionGate() -> some View {
        permissionGate(.calendar, .reminders)
    }
}
