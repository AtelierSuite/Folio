import Planner
import SwiftUI

struct EventTapSettingsSection: View {
    @AppStorage(EventTapSettings.behaviorKey, store: AppGroup.userDefaults)
    private var behavior = EventTapSettings.defaultBehavior

    var body: some View {
        Section {
            Picker(String(localized: "Settings.TapBehavior", table: "EventActions"), selection: $behavior) {
                ForEach(EventTapBehavior.allCases) { behavior in
                    Text(behavior.title).tag(behavior)
                }
            }
            .accessibilityIdentifier("EventTapBehaviorPicker")
        } header: {
            Text(String(localized: "Settings.Header", table: "EventActions"))
        } footer: {
            Text(String(localized: "Settings.TapBehavior.Footer", table: "EventActions"))
        }
    }
}

extension EventTapBehavior {
    var title: String {
        switch self {
        case .opensDetails: String(localized: "Settings.TapBehavior.OpensDetails", table: "EventActions")
        case .showsQuickActions: String(localized: "Settings.TapBehavior.ShowsQuickActions", table: "EventActions")
        }
    }
}
