import Foundation
import UserNotifications

public enum NotificationCategoryRegistry {
    public static func register(
        on center: UNUserNotificationCenter = .current(),
        snoozing durations: NotificationSnoozeDurations = NotificationSnoozeSettings().durations
    ) {
        center.setNotificationCategories(Set(allCategories(snoozing: durations)))
    }

    static func allCategories(snoozing durations: NotificationSnoozeDurations) -> [UNNotificationCategory] {
        let plain = NotificationCategory.allCases.map { makeCategory($0, snoozing: durations) }
        let perProvider = NotificationCategory.allCases.filter(\.offersJoin).flatMap { category in
            MeetingProvider.allCases.map { makeCategory(category, joining: $0, snoozing: durations) }
        }
        return plain + perProvider
    }

    static func makeCategory(
        _ category: NotificationCategory,
        joining provider: MeetingProvider? = nil,
        snoozing durations: NotificationSnoozeDurations = .standard
    ) -> UNNotificationCategory {
        UNNotificationCategory(
            identifier: category.identifier(joining: provider),
            actions: category.actions.map { makeAction($0, joining: provider, snoozing: durations) },
            intentIdentifiers: [],
            options: []
        )
    }

    private static func makeAction(
        _ action: NotificationAction,
        joining provider: MeetingProvider?,
        snoozing durations: NotificationSnoozeDurations
    ) -> UNNotificationAction {
        UNNotificationAction(
            identifier: action.identifier,
            title: action.title(joining: provider, snoozing: durations),
            options: action.opensApp ? [.foreground] : [],
            icon: UNNotificationActionIcon(systemImageName: action.systemImage(joining: provider))
        )
    }
}
