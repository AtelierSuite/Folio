import Planner
import UserNotifications

final class NotificationPresentationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationPresentationDelegate()

    private var responseHandler: NotificationResponseHandler?

    static func install(responseHandler: NotificationResponseHandler) {
        shared.responseHandler = responseHandler
        NotificationCategoryRegistry.register()
        UNUserNotificationCenter.current().delegate = shared
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        NotificationUserInfo.isKept(notification.request.content.userInfo) ? [.list] : [.banner, .list, .sound]
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        await responseHandler?.handle(
            actionIdentifier: response.actionIdentifier,
            content: response.notification.request.content
        )
    }
}
