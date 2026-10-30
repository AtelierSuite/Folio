import Foundation
import UserNotifications

public enum NotificationCategoryRegistry {
    public static func register(on center: UNUserNotificationCenter = .current()) {
        center.setNotificationCategories(Set(allCategories))
    }

    static var allCategories: [UNNotificationCategory] {
        let plain = NotificationCategory.allCases.map { makeCategory($0) }
        let perProvider = NotificationCategory.allCases.filter(\.offersJoin).flatMap { category in
            MeetingProvider.allCases.map { makeCategory(category, joining: $0) }
        }
        return plain + perProvider
    }

    static func makeCategory(
        _ category: NotificationCategory,
        joining provider: MeetingProvider? = nil
    ) -> UNNotificationCategory {
        UNNotificationCategory(
            identifier: category.identifier(joining: provider),
            actions: category.actions.map { makeAction($0, joining: provider) },
            intentIdentifiers: [],
            options: []
        )
    }

    private static func makeAction(
        _ action: NotificationAction,
        joining provider: MeetingProvider?
    ) -> UNNotificationAction {
        UNNotificationAction(
            identifier: action.identifier,
            title: action.title(joining: provider),
            options: action.opensApp ? [.foreground] : [],
            icon: UNNotificationActionIcon(systemImageName: action.systemImage(joining: provider))
        )
    }
}
