import Planner
import SwiftUI

struct FlexTimeProposalView: View {
    @Environment(FlexTimeCenter.self) private var flexTime
    let proposal: FlexTimeProposal
    @State private var firstEventStart: Date

    init(proposal: FlexTimeProposal) {
        self.proposal = proposal
        _firstEventStart = State(initialValue: proposal.suggestedStart)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                FlexTimeSheetHeader(proposal: proposal)
                FlexTimeStartPicker(proposal: proposal, firstEventStart: $firstEventStart)
                FlexTimeEventPreviewList(events: proposal.events, delay: delay)
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .safeAreaInset(edge: .bottom) {
            FlexTimeSheetActions(
                isActive: proposal.isActive,
                canDelay: delay > 0 || proposal.isActive,
                onUse: { Task { await flexTime.delay(proposal, startingFirstEventAt: firstEventStart) } },
                onDecline: decline
            )
        }
    }

    private var delay: TimeInterval {
        proposal.delay(startingFirstEventAt: firstEventStart)
    }

    private func decline() {
        if proposal.isActive {
            Task { await flexTime.turnOff(onDayOf: proposal.day) }
        } else {
            flexTime.dismissPrompt()
        }
    }
}
