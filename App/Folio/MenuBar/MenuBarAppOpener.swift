#if os(macOS)
import AppKit
import Planner
import SwiftUI

/// Brings Folio's main window forward, opening one if every window was closed, and shows `destination` in it.
struct MenuBarAppOpener {
    let openWindow: OpenWindowAction
    let requests: AppDestinationRequests

    func open(_ destination: AppDestination? = nil) {
        if let destination {
            requests.open(destination)
        }
        NSApp.activate()
        if let window = NSApp.windows.first(where: Self.isMainWindow) {
            if window.isMiniaturized {
                window.deminiaturize(nil)
            }
            window.makeKeyAndOrderFront(nil)
        } else {
            openWindow(id: FolioApp.mainWindowIdentifier)
        }
    }

    /// SwiftUI names a window group's windows after the group, as in `main-AppWindow-1`.
    private static func isMainWindow(_ window: NSWindow) -> Bool {
        window.identifier?.rawValue.hasPrefix("\(FolioApp.mainWindowIdentifier)-") == true
    }
}
#endif
