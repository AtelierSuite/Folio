import CoreGraphics
import Foundation
import Testing
@testable import Planner

struct TimelineDragHitTestTests {
    typealias Support = TimelineTestSupport

    private let geometry = TimelineGridGeometry(width: 200, dayCount: 2, hourHeight: 60)

    private func layout(_ entries: [TimelineEntry]) -> TimelineLayout {
        Support.engine(startingOn: Support.date(2026, 10, 27), count: 2).layout(entries)
    }

    private func target(_ layout: TimelineLayout, at point: CGPoint) -> TimelineDragTarget? {
        layout.dragTarget(at: point, geometry: geometry, minimumCardHeight: 16, handleHeight: 10)
    }

    @Test func findsTheCardUnderThePointer() {
        let layout = layout([
            Support.entry("a", from: Support.date(2026, 10, 27, 9), to: Support.date(2026, 10, 27, 10)),
            Support.entry("b", from: Support.date(2026, 10, 28, 9), to: Support.date(2026, 10, 28, 10))
        ])
        #expect(target(layout, at: CGPoint(x: 50, y: 570))?.placement.entry.id == "a")
        #expect(target(layout, at: CGPoint(x: 150, y: 570))?.placement.entry.id == "b")
        #expect(target(layout, at: CGPoint(x: 50, y: 700)) == nil)
        #expect(target(layout, at: CGPoint(x: 50, y: 570))?.kind == .move)
    }

    @Test func picksTheColumnOfOverlappingCards() {
        let layout = layout([
            Support.entry("a", from: Support.date(2026, 10, 27, 9), to: Support.date(2026, 10, 27, 10)),
            Support.entry("b", from: Support.date(2026, 10, 27, 9), to: Support.date(2026, 10, 27, 10))
        ])
        let left = target(layout, at: CGPoint(x: 20, y: 570))?.placement
        let right = target(layout, at: CGPoint(x: 80, y: 570))?.placement
        #expect(left != nil && right != nil && left != right)
    }

    @Test func handlesResizeTheEdges() {
        let layout = layout([
            Support.entry("a", from: Support.date(2026, 10, 27, 9), to: Support.date(2026, 10, 27, 10))
        ])
        #expect(target(layout, at: CGPoint(x: 50, y: 595))?.kind == .resizeEnd)
        #expect(target(layout, at: CGPoint(x: 50, y: 543))?.kind == .resizeStart)
    }

    @Test func shortCardsOnlyMove() {
        let layout = layout([
            Support.entry("a", from: Support.date(2026, 10, 27, 9), to: Support.date(2026, 10, 27, 9, 20))
        ])
        #expect(target(layout, at: CGPoint(x: 50, y: 559))?.kind == .move)
    }

    @Test func readOnlyItemsCantBeDragged() {
        var entry = Support.entry("a", from: Support.date(2026, 10, 27, 9), to: Support.date(2026, 10, 27, 10))
        entry.isReadOnly = true
        #expect(target(layout([entry]), at: CGPoint(x: 50, y: 570)) == nil)
    }

    @Test func remindersOnlyMove() {
        var entry = Support.entry("r", from: Support.date(2026, 10, 27, 9), to: Support.date(2026, 10, 27, 10))
        entry.kind = .reminder
        #expect(target(layout([entry]), at: CGPoint(x: 50, y: 595))?.kind == .move)
    }
}
