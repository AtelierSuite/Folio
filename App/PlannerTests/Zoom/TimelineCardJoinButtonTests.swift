import CoreGraphics
import Testing
@testable import Planner

struct TimelineCardJoinButtonTests {
    private let resolver = TimelineCardDetailResolver(
        metrics: TimelineCardTextMetrics(titlePointSize: 12, detailPointSize: 11), compressesText: false
    )

    private func showsJoinButton(width: CGFloat, height: CGFloat) -> Bool {
        let size = CGSize(width: width, height: height)
        return resolver.showsJoinButton(for: resolver.presentation(for: size), cardSize: size, buttonWidth: 24)
    }

    @Test func showsOnCardsWithRoomForTheTime() {
        #expect(showsJoinButton(width: 200, height: 120))
        #expect(showsJoinButton(width: 200, height: 36))
    }

    @Test func hidesOnTitleOnlyCardsAndBars() {
        #expect(!showsJoinButton(width: 200, height: 16))
        #expect(!showsJoinButton(width: 200, height: 6))
    }

    @Test func hidesWhenItWouldCrowdTheTitle() {
        let minimumWidth = resolver.minimumWidth(textScale: 1)
        #expect(!showsJoinButton(width: minimumWidth + 10, height: 120))
        #expect(showsJoinButton(width: minimumWidth + 24, height: 120))
    }
}
