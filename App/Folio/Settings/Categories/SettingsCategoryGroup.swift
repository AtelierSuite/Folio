import Foundation
import Planner

struct SettingsCategoryGroup: Hashable {
    let header: String?
    let categories: [SettingsCategory]

    func availableCategories(with capabilities: PlatformCapabilities) -> [SettingsCategory] {
        categories.filter { $0.isAvailable(with: capabilities) }
    }

    static var groups: [SettingsCategoryGroup] {
        groups(including: [.search])
    }

    static var windowGroups: [SettingsCategoryGroup] {
        groups(including: [.search, .privacy])
    }

    private static func groups(including systemCategories: [SettingsCategory]) -> [SettingsCategoryGroup] {
        var groups = [
            SettingsCategoryGroup(header: nil, categories: [.accounts, .general]),
            SettingsCategoryGroup(
                header: String(localized: "Group.CalendarsAndNotes", table: "Settings"),
                categories: [.calendars, .workWeek, .notes]
            ),
            SettingsCategoryGroup(
                header: String(localized: "Group.NotificationsAndAlarms", table: "Settings"),
                categories: [.notifications, .eventNotifications, .reminderNotifications, .alarms, .countdowns]
            ),
            SettingsCategoryGroup(
                header: String(localized: "Group.Integrations", table: "Settings"),
                categories: [.weather, .sleep]
            ),
            SettingsCategoryGroup(
                header: String(localized: "Group.System", table: "Settings"),
                categories: systemCategories
            )
        ]
        #if DEBUG
        if !ScreenshotStage.isActive {
            groups.append(SettingsCategoryGroup(
                header: String(localized: "Group.Developer", table: "Settings"),
                categories: [.debug]
            ))
        }
        #endif
        return groups
    }
}
