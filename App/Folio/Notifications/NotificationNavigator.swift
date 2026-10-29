import Foundation
import Observation
import Planner

/// Holds where a notification response asked to go until a scene is active to show it,
/// see `View.handlesNotificationRoutes()`.
@Observable
final class NotificationNavigator: NotificationRouting {
    var pendingRoute: NotificationRoute?

    func open(_ route: NotificationRoute) {
        pendingRoute = route
    }
}
