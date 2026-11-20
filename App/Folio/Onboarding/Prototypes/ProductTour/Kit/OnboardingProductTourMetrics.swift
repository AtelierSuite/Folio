import SwiftUI

enum OnboardingProductTourMetrics {
    #if os(macOS)
    static let deviceSize = CGSize(width: 340, height: 214)
    static let titleBarHeight: CGFloat = 24
    static let statusBarHeight: CGFloat = 0
    static let navBarHeight: CGFloat = 20
    static let visibleHours = 4.0
    static let reminderRowHeight: CGFloat = 24
    static let fingertipSize: CGFloat = 20
    static let stageHeight: CGFloat = 250
    #else
    static let deviceSize = CGSize(width: 172, height: 356)
    static let bezelWidth: CGFloat = 6
    static let screenCornerRadius: CGFloat = 30
    static let statusBarHeight: CGFloat = 28
    static let navBarHeight: CGFloat = 24
    static let visibleHours = 6.5
    static let reminderRowHeight: CGFloat = 32
    static let fingertipSize: CGFloat = 24
    static let stageHeight: CGFloat = 380
    #endif
}
