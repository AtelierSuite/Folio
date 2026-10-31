#if os(macOS)
import AppKit
import SwiftUI

extension PlatformMenuAnchor: NSViewRepresentable {
    func makeNSView(context: Context) -> PlatformMenuAnchorView {
        PlatformMenuAnchorView()
    }

    func updateNSView(_ view: PlatformMenuAnchorView, context: Context) {
        guard let request = shouldPresent(context.coordinator) else { return }
        let menu = request.menu().menu()
        Task { @MainActor in
            menu.popUp(positioning: nil, at: .zero, in: view)
        }
    }
}

/// Lets every click through to the views below.
final class PlatformMenuAnchorView: NSView {
    override var isFlipped: Bool {
        true
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        nil
    }
}
#endif
