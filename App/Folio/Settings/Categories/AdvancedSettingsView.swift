import Planner
import SwiftUI

struct AdvancedSettingsView: View {
    @Environment(NotificationScheduler.self) private var scheduler

    var body: some View {
        Form {
            NotificationStatusSection()
        }
        .settingsCategoryStyle(.advanced)
        .task {
            await scheduler.replan()
        }
    }
}
