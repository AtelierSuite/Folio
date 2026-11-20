import SwiftUI

nonisolated struct OnboardingCarouselParallax: GeometryEffect {
    var progress: Double
    let pageIndex: Int
    let factor: Double

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let distance = Double(pageIndex) - progress
        return ProjectionTransform(CGAffineTransform(translationX: distance * size.width * factor, y: 0))
    }
}

extension View {
    func onboardingCarouselParallax(pageIndex: Int, currentIndex: Int, factor: Double) -> some View {
        modifier(OnboardingCarouselParallax(progress: Double(currentIndex), pageIndex: pageIndex, factor: factor))
    }
}
