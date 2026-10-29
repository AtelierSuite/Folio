import Foundation
import UserNotifications

public enum NotificationCategoryRegistry {
    public static func register(on center: UNUserNotificationCenter = .current()) {
        center.setNotificationCategories(Set(NotificationCategory.allCases.map(makeCategory)))
    }

    static func makeCategory(_ category: NotificationCategory) -> UNNotificationCategory {
        UNNotificationCategory(
            identifier: category.rawValue,
            actions: category.actions.map(makeAction),
            intentIdentifiers: [],
            options: []
        )
    }

    private static func makeAction(_ action: NotificationAction) -> UNNotificationAction {
        UNNotificationAction(
            identifier: action.identifier,
            title: action.title,
            options: action.opensApp ? [.foreground] : [],
            icon: UNNotificationActionIcon(systemImageName: action.systemImage)
        )
    }
}
