import Foundation

/// The Flex Time sheet's content. Without a proposal the day has no events to delay.
public struct FlexTimePrompt: Sendable, Hashable, Identifiable {
    public let day: Date
    public let proposal: FlexTimeProposal?

    public init(day: Date, proposal: FlexTimeProposal?) {
        self.day = day
        self.proposal = proposal
    }

    public var id: Date { day }
}
