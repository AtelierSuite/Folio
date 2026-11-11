import Planner
import SwiftUI

struct FlexTimeStartPicker: View {
    let proposal: FlexTimeProposal
    @Binding var firstEventStart: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            DatePicker(
                String(localized: "Prompt.FirstEventStart", table: "FlexTime"),
                selection: $firstEventStart,
                in: proposal.startRange,
                displayedComponents: .hourAndMinute
            )
            .fontWeight(.medium)
            .accessibilityIdentifier("FlexTimeStartPicker")
            Text(summary)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 16)
        .background(.fill.tertiary, in: .rect(cornerRadius: 16))
    }

    private var summary: String {
        let delay = proposal.delay(startingFirstEventAt: firstEventStart)
        guard delay > 0 else {
            return String(localized: "Prompt.NoDelay", table: "FlexTime")
        }
        let delayText = String(localized: "Prompt.Delay \(FlexTimeFormatting.duration(delay))", table: "FlexTime")
        guard let wake = proposal.wake, wake.source == .sleep, firstEventStart > wake.time else {
            return delayText
        }
        let sinceWaking = FlexTimeFormatting.duration(firstEventStart.timeIntervalSince(wake.time))
        return String(localized: "Prompt.AfterWaking \(sinceWaking)", table: "FlexTime") + "\n" + delayText
    }
}
