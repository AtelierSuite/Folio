import Planner
import SwiftUI

struct SleepSettingsView: View {
    @Environment(\.platformCapabilities) private var capabilities
    @Environment(SleepStore.self) private var store
    @State private var summary: SleepSummary?

    var body: some View {
        Form {
            if isSleepShown, let lastNight = summary?.lastNight {
                SleepLastNightHero(lastNight: lastNight)
            }
            PermissionPromptSection(
                kind: .health,
                message: String(localized: "Prompt.Sleep", table: "Permissions"),
                asksOnToggle: true
            )
            SleepSettingsSection(summary: isSleepShown ? summary : nil)
        }
        .settingsCategoryStyle(.sleep)
        .task(id: LoadKey(revision: store.revision, isShown: isSleepShown)) {
            summary = isSleepShown ? await SleepSummary(store: store) : nil
        }
    }

    private var isSleepShown: Bool {
        capabilities.supports(.sleep) && store.isAvailable && store.isShownOnTimeline
    }

    private struct LoadKey: Equatable {
        let revision: Int
        let isShown: Bool
    }
}
