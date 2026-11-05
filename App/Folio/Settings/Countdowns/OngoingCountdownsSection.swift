import Planner
import SwiftUI

struct OngoingCountdownsSection: View {
    @Environment(EventCountdownManager.self) private var countdowns

    var body: some View {
        Section {
            if countdowns.running.isEmpty {
                Text(String(localized: "Settings.Ongoing.Empty", table: "Countdown"))
                    .foregroundStyle(.secondary)
            } else {
                ForEach(countdowns.running) { countdown in
                    OngoingCountdownRow(countdown: countdown) {
                        Task { await countdowns.dismiss(countdown) }
                    }
                }
            }
        } header: {
            Text(String(localized: "Settings.Ongoing.Header", table: "Countdown"))
        }
    }
}
