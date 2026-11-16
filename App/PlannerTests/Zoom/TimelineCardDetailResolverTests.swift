import CoreGraphics
import Testing
@testable import Planner

struct TimelineCardDetailResolverTests {
    let metrics = TimelineCardTextMetrics(titlePointSize: 12, detailPointSize: 11)

    private func resolver(
        compressing: Bool = false, metrics: TimelineCardTextMetrics? = nil
    ) -> TimelineCardDetailResolver {
        TimelineCardDetailResolver(metrics: metrics ?? self.metrics, compressesText: compressing)
    }

    private func detail(height: CGFloat, width: CGFloat = 200, compressing: Bool = false) -> TimelineCardDetail {
        resolver(compressing: compressing).presentation(for: CGSize(width: width, height: height)).detail
    }

    @Test func detailDropsAsTheCardShrinks() {
        #expect(detail(height: 120) == .full)
        #expect(detail(height: 36) == .titleAndTime)
        #expect(detail(height: 16) == .title)
        #expect(detail(height: 6) == .bar)
    }

    @Test func eachLevelNeedsMoreRoomThanTheOneBelow() {
        let heights = TimelineCardDetail.allCases.map { resolver().requiredHeight(for: $0) }
        #expect(heights == heights.sorted())
        #expect(Set(heights).count == heights.count)
    }

    @Test func cardOfExactlyTheRequiredHeightGetsThatLevel() {
        for level in [TimelineCardDetail.titleAndTime, .full] {
            let height = resolver().requiredHeight(for: level)
            #expect(detail(height: height) == level)
            #expect(detail(height: height - 0.5) < level)
        }
    }

    @Test func shortTitleOnlyCardsDropTheirPadding() {
        let tight = resolver().presentation(for: CGSize(width: 200, height: 13))
        #expect(tight.detail == .title)
        #expect(!tight.showsPadding)
        let roomy = resolver().presentation(for: CGSize(width: 200, height: 20))
        #expect(roomy.showsPadding)
    }

    @Test func narrowCardsBecomeBars() {
        #expect(detail(height: 120, width: 20) == .bar)
        #expect(detail(height: 120, width: 40) == .full)
    }

    @Test func thresholdsGrowWithDynamicType() {
        let large = TimelineCardTextMetrics(titlePointSize: 20, detailPointSize: 18)
        let presentation = resolver(metrics: large).presentation(for: CGSize(width: 200, height: 36))
        #expect(presentation.detail == .title)
        #expect(detail(height: 36) == .titleAndTime)
    }

    @Test func compressModeKeepsTheSameDetailForTheHeight() {
        for height in stride(from: CGFloat(4), through: 200, by: 1.5) {
            #expect(detail(height: height, compressing: true) == detail(height: height))
        }
    }

    @Test func compressModeKeepsNarrowerCardsAsText() {
        #expect(detail(height: 120, width: 20, compressing: true) == .full)
        #expect(detail(height: 120, width: 20) == .bar)
    }

    @Test func tallCardsWrapTheTitle() {
        let presentation = resolver().presentation(for: CGSize(width: 200, height: 300))
        #expect(presentation.titleLineLimit == metrics.maximumTitleLines)
        #expect(resolver().presentation(for: CGSize(width: 200, height: 45)).titleLineLimit == 1)
    }
}
