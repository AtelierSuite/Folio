import Planner
import SwiftUI

struct CountdownPhasesSection: View {
    @Environment(EventCountdownManager.self) private var countdowns
    @AppStorage(CountdownSettings.countsToStartKey, store: AppGroup.userDefaults)
    private var countsToStart = true
    @AppStorage(CountdownSettings.countsToEndKey, store: AppGroup.userDefaults)
    private var countsToEnd = true

    var body: some View {
        Section {
            Toggle(String(localized: "Settings.Phases.TimeToStart", table: "Countdown"), isOn: $countsToStart)
                .disabled(!countsToEnd)
                .accessibilityIdentifier("CountdownPhases.TimeToStart")
            Toggle(String(localized: "Settings.Phases.TimeToEnd", table: "Countdown"), isOn: $countsToEnd)
                .disabled(!countsToStart)
                .accessibilityIdentifier("CountdownPhases.TimeToEnd")
        } header: {
            Text(String(localized: "Settings.Phases.Header", table: "Countdown"))
        } footer: {
            Text(String(localized: "Settings.Phases.Footer", table: "Countdown"))
        }
        .onChange(of: CountdownPhases(countsToStart: countsToStart, countsToEnd: countsToEnd)) {
            Task { await countdowns.reconcile() }
        }
    }
}
