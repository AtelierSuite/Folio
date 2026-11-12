import SwiftUI

struct OnboardingTimelineItem: Identifiable {
    enum Placement {
        case block
        case reminder
        case gutter
        case notification
    }

    let id: Int
    let placement: Placement
    let start: CGFloat
    var length: CGFloat = 1
    var color: Color = .gray
    var symbol: String?
    var isAnimated = true

    var spansFullWidth: Bool {
        placement == .notification
    }
}
