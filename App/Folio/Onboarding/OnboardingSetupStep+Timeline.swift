import SwiftUI

extension OnboardingSetupStep {
    var timelineItems: [OnboardingTimelineItem] {
        let items = animatedItems
        let background = backgroundBlocks.enumerated().map { index, block in
            OnboardingTimelineItem(
                id: items.count + index,
                placement: .block,
                start: block.start,
                length: block.length,
                isAnimated: false
            )
        }
        return background + items
    }

    private var backgroundBlocks: [(start: CGFloat, length: CGFloat)] {
        switch self {
        case .calendar: []
        case .reminders: [(0.3, 1.2), (3, 1.2)]
        case .alerts: [(0.3, 1.2), (1.9, 1), (3.3, 1.4)]
        case .weather: [(0.6, 1.4), (2.8, 1.2)]
        case .sleep: [(2.6, 1), (3.8, 1)]
        }
    }

    private var animatedItems: [OnboardingTimelineItem] {
        switch self {
        case .calendar:
            [
                OnboardingTimelineItem(id: 0, placement: .block, start: 0.3, length: 1.2, color: .red),
                OnboardingTimelineItem(id: 1, placement: .block, start: 1.9, length: 1, color: .blue),
                OnboardingTimelineItem(id: 2, placement: .block, start: 3.3, length: 1.4, color: .green)
            ]
        case .reminders:
            [
                OnboardingTimelineItem(id: 0, placement: .reminder, start: 1.7, color: .orange),
                OnboardingTimelineItem(id: 1, placement: .reminder, start: 2.3, color: .purple),
                OnboardingTimelineItem(id: 2, placement: .reminder, start: 4.4, color: .blue)
            ]
        case .alerts:
            [
                OnboardingTimelineItem(id: 0, placement: .badge, start: 0.3, color: .orange),
                OnboardingTimelineItem(id: 1, placement: .badge, start: 1.9, color: .orange),
                OnboardingTimelineItem(id: 2, placement: .badge, start: 3.3, color: .orange)
            ]
        case .weather:
            ["sun.max.fill", "cloud.sun.fill", "cloud.fill", "cloud.rain.fill", "cloud.sun.fill"]
                .enumerated()
                .map { index, symbol in
                    OnboardingTimelineItem(id: index, placement: .gutter, start: CGFloat(index), symbol: symbol)
                }
        case .sleep:
            [
                OnboardingTimelineItem(
                    id: 0,
                    placement: .block,
                    start: 0.1,
                    length: 2.2,
                    color: .indigo,
                    symbol: "bed.double.fill"
                )
            ]
        }
    }
}
