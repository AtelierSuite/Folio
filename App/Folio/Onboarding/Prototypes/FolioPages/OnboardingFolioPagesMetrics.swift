import SwiftUI

enum OnboardingFolioPagesMetrics {
    #if os(macOS)
    static let pageSize = CGSize(width: 250, height: 210)
    static let sectionSpacing: CGFloat = 26
    static let rowSpacing: CGFloat = 18
    #else
    static let pageSize = CGSize(width: 262, height: 288)
    static let sectionSpacing: CGFloat = 36
    static let rowSpacing: CGFloat = 28
    #endif
    static let stackReserve: CGFloat = 30
    static let boardPadding: CGFloat = 10
    static let sliverStep: CGFloat = 4
    static let marginInset: CGFloat = 30
    static let turnDuration: TimeInterval = 0.85
    static let coverDelay: TimeInterval = 0.5
    static let coverDuration: TimeInterval = 1.1

    static var bookSize: CGSize {
        CGSize(
            width: pageSize.width + stackReserve + boardPadding * 2,
            height: pageSize.height + boardPadding * 2
        )
    }

    static var pageOrigin: CGPoint {
        CGPoint(x: boardPadding + stackReserve, y: boardPadding)
    }
}
