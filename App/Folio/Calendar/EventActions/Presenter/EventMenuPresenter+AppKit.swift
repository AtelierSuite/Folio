#if os(macOS)
import AppKit
import Planner
import SwiftUI

extension EventMenuPresenter: NSViewRepresentable {
    func makeNSView(context: Context) -> EventMenuAnchorView {
        EventMenuAnchorView()
    }

    func updateNSView(_ view: EventMenuAnchorView, context: Context) {
        guard let request = shouldPresent(context.coordinator) else { return }
        let menu = EventPlatformMenu(event: request.event, actions: actions).menu()
        Task { @MainActor in
            menu.popUp(positioning: nil, at: request.point, in: view)
        }
    }
}

/// Lets every click through to the cards below.
final class EventMenuAnchorView: NSView {
    override var isFlipped: Bool {
        true
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        nil
    }
}
#endif
