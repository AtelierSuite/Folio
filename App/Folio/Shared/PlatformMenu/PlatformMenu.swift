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
    let opening: PlatformMenuOpening
    let point: CGPoint
    let menu: @MainActor () -> PlatformMenu
}

/// Remembers that a menu request has opened. It lives with the request, not the anchor, because
/// SwiftUI rebuilds the anchor when the calendar switches views, and a new anchor opened it again.
final class PlatformMenuOpening: Equatable {
    private var hasOpened = false

    func markOpened() -> Bool {
        guard !hasOpened else { return false }
        hasOpened = true
        return true
    }

    nonisolated static func == (lhs: PlatformMenuOpening, rhs: PlatformMenuOpening) -> Bool {
        lhs === rhs
    }
}
