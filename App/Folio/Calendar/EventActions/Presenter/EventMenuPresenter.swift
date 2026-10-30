import Planner
import SwiftUI

/// Opens the quick actions at the point an event was tapped. SwiftUI can only open a menu from
/// its own label or on a long press, so this hands the same items to UIKit or AppKit.
struct EventMenuPresenter {
    let request: EventMenuRequest?
    let actions: EventActions

    final class Coordinator {
        var presentedRequestID: UUID?
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func shouldPresent(_ coordinator: Coordinator) -> EventMenuRequest? {
        guard let request, request.id != coordinator.presentedRequestID else { return nil }
        coordinator.presentedRequestID = request.id
        return request
    }
}
