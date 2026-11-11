import Planner
import SwiftUI

struct FlexTimeSheetHeader: View {
    let proposal: FlexTimeProposal

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.largeTitle)
                .foregroundStyle(.tint)
                .accessibilityHidden(true)
            Text(title)
                .font(.largeTitle.bold())
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("FlexTimeTitle")
            Text(message)
                .foregroundStyle(.secondary)
        }
    }

    private var title: String {
        proposal.isActive
            ? String(localized: "Prompt.Title.Active", table: "FlexTime")
            : String(localized: "Prompt.Title", table: "FlexTime")
    }

    private var message: String {
        let firstStart = FlexTimeFormatting.time(proposal.firstEvent?.startDate ?? proposal.day)
        guard let wake = proposal.wake else {
            return String(localized: "Prompt.Message \(firstStart)", table: "FlexTime")
        }
        let wakeTime = FlexTimeFormatting.time(wake.time)
        switch wake.source {
        case .sleep:
            return String(localized: "Prompt.Message.Sleep \(wakeTime) \(firstStart)", table: "FlexTime")
        case .firstOpen:
            return String(localized: "Prompt.Message.FirstOpen \(wakeTime) \(firstStart)", table: "FlexTime")
        }
    }
}
