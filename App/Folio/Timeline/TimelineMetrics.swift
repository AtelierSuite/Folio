import SwiftUI

struct TimelineMetrics {
    var hourLabelWidth: CGFloat = 60
    var allDayLaneHeight: CGFloat = 22
    var maximumVisibleAllDayLanes: CGFloat = 3.5
    var minimumCardHeight: CGFloat = 16
    var verticalInset: CGFloat = 10

    /// Short events keep a tappable height, but not so much that they cover the next hour when zoomed out.
    func minimumCardHeight(hourHeight: CGFloat) -> CGFloat {
        min(minimumCardHeight, hourHeight / 2)
    }

    /// The `.caption` and `.caption2` sizes at the default Dynamic Type size; cards scale them with `@ScaledMetric`.
    /// `JoinMeetingIcon`'s diameter plus its inset on both sides.
    static let joinButtonWidth: CGFloat = 26
    static let joinButtonInset: CGFloat = 3

    #if os(macOS)
    static let cardTitlePointSize: CGFloat = 10
    static let cardDetailPointSize: CGFloat = 10
    #else
    static let cardTitlePointSize: CGFloat = 12
    static let cardDetailPointSize: CGFloat = 11
    #endif
}
