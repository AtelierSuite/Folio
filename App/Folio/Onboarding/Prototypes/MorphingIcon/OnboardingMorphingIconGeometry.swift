import SwiftUI

enum OnboardingMorphingIconGeometry {
    static func offset(degrees: Double, radius: CGFloat, verticalScale: CGFloat = 1) -> CGSize {
        let radians = degrees * .pi / 180
        return CGSize(width: cos(radians) * radius, height: sin(radians) * radius * verticalScale)
    }
}
