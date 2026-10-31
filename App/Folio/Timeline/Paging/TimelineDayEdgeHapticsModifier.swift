import SwiftUI

/// Ticks each time a day's edge scrolls into view while the user swipes or flings the pages.
struct TimelineDayEdgeHapticsModifier: ViewModifier {
    let columnsOnScreen: Int
    @State private var leadingColumn = 0
    @State private var scrollPhase = ScrollPhase.idle

    func body(content: Content) -> some View {
        content
            .onScrollPhaseChange { _, phase in scrollPhase = phase }
            .onScrollGeometryChange(for: Int.self) { geometry in
                let columnWidth = geometry.containerSize.width / CGFloat(max(columnsOnScreen, 1))
                guard columnWidth > 0 else { return 0 }
                return max(Int(((geometry.contentOffset.x + 0.5) / columnWidth).rounded(.down)), 0)
            } action: { _, column in
                leadingColumn = column
            }
            .sensoryFeedback(.selection, trigger: leadingColumn) { _, _ in
                scrollPhase == .interacting || scrollPhase == .decelerating
            }
    }
}
