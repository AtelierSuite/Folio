import SwiftUI

/// Opens a menu at a point. SwiftUI can only open a menu from its own label or on a long press,
/// so this hands the items to UIKit or AppKit. Each request opens once.
struct PlatformMenuPresenter: View {
    let request: PlatformMenuRequest?

    /// The anchor is moved to the point itself: UIKit places a button's menu by the button's
    /// superview, so a button moved inside a full-size view opened its menu at the top of the screen.
    var body: some View {
        PlatformMenuAnchor(request: request)
            .frame(width: 1, height: 1)
            .position(request?.point ?? .zero)
            .allowsHitTesting(false)
    }
}

struct PlatformMenuAnchor {
    let request: PlatformMenuRequest?

    final class Coordinator {
        var presentedRequestID: UUID?
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func shouldPresent(_ coordinator: Coordinator) -> PlatformMenuRequest? {
        guard let request, request.id != coordinator.presentedRequestID else { return nil }
        coordinator.presentedRequestID = request.id
        return request
    }
}
