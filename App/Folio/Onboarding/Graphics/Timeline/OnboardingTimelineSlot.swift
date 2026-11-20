import CoreGraphics

struct OnboardingTimelineSlot {
    let start: Double
    let duration: Double
    var lane = 0
    var laneCount = 1
}

struct OnboardingTimelineMetrics {
    static let gutter: CGFloat = 30
    static let laneSpacing: CGFloat = 4

    let size: CGSize
    let hourCount: Int

    var hourHeight: CGFloat { size.height / CGFloat(hourCount) }

    func y(at hour: Double) -> CGFloat {
        CGFloat(hour) * hourHeight
    }

    func frame(for slot: OnboardingTimelineSlot) -> CGRect {
        let laneArea = size.width - Self.gutter
        let laneWidth = (laneArea - Self.laneSpacing * CGFloat(slot.laneCount - 1)) / CGFloat(slot.laneCount)
        return CGRect(
            x: Self.gutter + CGFloat(slot.lane) * (laneWidth + Self.laneSpacing),
            y: y(at: slot.start),
            width: laneWidth,
            height: CGFloat(slot.duration) * hourHeight - 2
        )
    }
}
