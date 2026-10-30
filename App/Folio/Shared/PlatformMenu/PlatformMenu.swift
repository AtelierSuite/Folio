import SwiftUI

/// Menu sections handed to UIKit or AppKit, for menus opened at a point.
@MainActor
struct PlatformMenu {
    struct Entry {
        let title: String
        let systemImage: String
        var isDestructive = false
        let identifier: String
        var children: [Entry] = []
        let action: @MainActor () -> Void
    }

    let sections: [[Entry]]
}

struct PlatformMenuRequest {
    let id: UUID
    let point: CGPoint
    let menu: @MainActor () -> PlatformMenu
}
