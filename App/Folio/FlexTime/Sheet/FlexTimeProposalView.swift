import Planner
import SwiftUI

struct FlexTimeProposalView: View {
    @Environment(FlexTimeCenter.self) private var flexTime
    let proposal: FlexTimeProposal
    @State private var firstEventStart: Date
    @State private var excludedCalendars: Set<String>

    init(proposal: FlexTimeProposal) {
        self.proposal = proposal
        _firstEventStart = State(initialValue: proposal.suggestedStart)
        _excludedCalendars = State(initialValue: proposal.activeExcludedCalendars)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                FlexTimeSheetHeader(proposal: proposal)
                FlexTimeStartPicker(
                    proposal: proposal, excludedCalendars: excludedCalendars, firstEventStart: $firstEventStart
                )
                FlexTimeEventPreviewList(
                    events: proposal.events, delay: delay, excludedCalendars: $excludedCalendars
                )
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onChange(of: excludedCalendars) { previous, current in
            keepDelay(from: previous, to: current)
        }
        .safeAreaBar(edge: .bottom) {
            FlexTimeSheetActions(
                isActive: proposal.isActive,
                canDelay: delay > 0 || proposal.isActive,
                onUse: use,
                onDecline: decline
            )
        }
    }

    private var delay: TimeInterval {
        proposal.delay(startingFirstEventAt: firstEventStart, excluding: excludedCalendars)
    }

    private func keepDelay(from previous: Set<String>, to current: Set<String>) {
        let range = proposal.startRange(excluding: current)
        let previousDelay = proposal.delay(startingFirstEventAt: firstEventStart, excluding: previous)
        guard previousDelay > 0, let firstEvent = proposal.firstEvent(excluding: current) else {
            firstEventStart = min(max(firstEventStart, range.lowerBound), range.upperBound)
            return
        }
        firstEventStart = min(firstEvent.startDate.addingTimeInterval(previousDelay), range.upperBound)
    }

    private func use() {
        Task {
            await flexTime.delay(proposal, startingFirstEventAt: firstEventStart, excluding: excludedCalendars)
        }
    }

    private func decline() {
        if proposal.isActive {
            Task { await flexTime.turnOff(onDayOf: proposal.day) }
        } else {
            flexTime.dismissPrompt()
        }
    }
}
