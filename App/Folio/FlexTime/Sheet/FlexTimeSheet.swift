import Planner
import SwiftUI

struct FlexTimeSheet: View {
    let prompt: FlexTimePrompt

    var body: some View {
        Group {
            if let proposal = prompt.proposal {
                FlexTimeProposalView(proposal: proposal)
            } else {
                FlexTimeNoEventsView()
            }
        }
        #if os(macOS)
        .frame(width: 440)
        .frame(minHeight: 420)
        #endif
    }
}
