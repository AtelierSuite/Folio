import Foundation
import Testing
@testable import Planner

struct AttendeeSummaryTests {
    private func attendees(_ statuses: [ParticipantStatus]) -> [EventParticipant] {
        statuses.enumerated().map { index, status in
            InvitationFixtures.participant("Person\(index)", status: status)
        }
    }

    @Test func countsEachResponse() {
        let summary = AttendeeSummary(attendees([.accepted, .accepted, .tentative, .declined, .pending, .unknown]))
        #expect(summary.count(of: .accepted) == 2)
        #expect(summary.count(of: .tentative) == 1)
        #expect(summary.count(of: .declined) == 1)
        #expect(summary.count(of: .pending) == 2)
        #expect(summary.total == 6)
    }

    @Test func describesNonZeroCountsInResponseOrder() {
        let summary = AttendeeSummary(attendees([.pending, .accepted, .accepted, .accepted, .accepted]))
        let english = Locale(identifier: "en_US")
        #expect(summary.parts(locale: english) == ["4 accepted", "1 pending"])
        #expect(summary.description(locale: english) == "4 accepted, 1 pending")
        #expect(summary.parts(locale: Locale(identifier: "ja_JP")) == ["承諾 4", "未返答 1"])
    }

    @Test func emptyAttendeesHaveNoDescription() {
        let summary = AttendeeSummary([])
        #expect(summary.total == 0)
        #expect(summary.parts().isEmpty)
    }

    @Test func statusesMapToResponses() {
        #expect(ParticipantStatus.completed.response == .accepted)
        #expect(ParticipantStatus.delegated.response == .pending)
        #expect(ParticipantStatus.inProcess.response == .pending)
        #expect(ParticipantStatus.unknown.response == .pending)
        #expect(ParticipantStatus.tentative.response == .tentative)
        #expect(ParticipantStatus.declined.response == .declined)
    }
}
