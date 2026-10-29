import Testing
@testable import Planner

struct MonthCellOverflowTests {
    @Test func everythingFits() {
        let overflow = MonthCellOverflow(itemCount: 3, capacity: 3)
        #expect(overflow.visibleCount == 3)
        #expect(overflow.hiddenCount == 0)
    }

    @Test func moreLabelTakesTheLastRow() {
        let overflow = MonthCellOverflow(itemCount: 5, capacity: 3)
        #expect(overflow.visibleCount == 2)
        #expect(overflow.hiddenCount == 3)
    }

    @Test func noRoomShowsOnlyTheCount() {
        let overflow = MonthCellOverflow(itemCount: 2, capacity: 0)
        #expect(overflow.visibleCount == 0)
        #expect(overflow.hiddenCount == 2)
    }

    @Test func capacityCountsWholeRows() {
        #expect(MonthCellOverflow.capacity(height: 50, rowHeight: 16, spacing: 2) == 2)
        #expect(MonthCellOverflow.capacity(height: 52, rowHeight: 16, spacing: 2) == 3)
        #expect(MonthCellOverflow.capacity(height: 10, rowHeight: 16, spacing: 2) == 0)
    }
}
