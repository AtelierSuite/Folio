import Planner
import SwiftUI

/// Menu sections handed to UIKit or AppKit, for menus opened at a point.
@MainActor
struct PlatformMenu {
    struct Entry {
        let title: String
        let systemImage: String
        var symbolColor: PlannerColor?
        var isDestructive = false
        let identifier: String
        var children: [ChildSection] = []
        let action: @MainActor () -> Void
    }

    struct ChildSection {
        let title: String
        let entries: [Entry]
    }

    let sections: [[Entry]]
}

struct PlatformMenuRequest {
    let id: UUID
    let point: CGPoint
    let menu: @MainActor () -> PlatformMenu
}
