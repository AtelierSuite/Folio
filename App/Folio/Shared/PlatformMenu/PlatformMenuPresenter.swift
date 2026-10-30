import SwiftUI

/// Opens a menu at a point. SwiftUI can only open a menu from its own label or on a long press,
/// so this hands the items to UIKit or AppKit. Each request opens once.
struct PlatformMenuPresenter {
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
