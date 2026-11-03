#if DEBUG
import Foundation
import Planner

/// The scene an App Store screenshot shows, set with `-FolioScreenshotStage <name>` by `Assets/App Store/capture.sh`
/// and `capture-mac.sh`. Debug builds only.
enum ScreenshotStage: String {
    case week
    case lists
    case notes
    case alarms
    case notifications
    case countdown

    private static let key = "FolioScreenshotStage"

    static var requested: ScreenshotStage? {
        UserDefaults.standard.string(forKey: key).flatMap(ScreenshotStage.init(rawValue:))
    }

    static var isActive: Bool {
        requested != nil || ProcessInfo.processInfo.arguments.contains(ScreenshotSamples.launchArgument)
    }

    /// Sets what the views read from their settings when they first appear, so it runs before any of them do.
    static func prepareSettings() {
        guard let stage = requested else { return }
        let defaults = UserDefaults.standard
        defaults.set(stage.viewMode.rawValue, forKey: "Calendar.ViewMode")
        defaults.set(SettingsCategory.eventNotifications.rawValue, forKey: "SettingsWindow.selectedCategory")
        SleepPreferences().showsOnTimeline = true
    }

    var tab: AppTab {
        switch self {
        case .week, .alarms, .countdown: .calendar
        case .lists: .lists
        case .notes: .notes
        case .notifications: PlatformCapabilities.current.platform == .mac ? .calendar : .settings
        }
    }

    private var viewMode: CalendarViewMode {
        self == .alarms ? .day : .workWeek
    }
}
#endif
