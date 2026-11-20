import SwiftUI

struct OnboardingCarouselScene: View {
    static let canvasSize = CGSize(width: 320, height: 260)

    let page: OnboardingCarouselPage
    let features: [OnboardingFeature]
    let isActive: Bool

    var body: some View {
        GeometryReader { proxy in
            let scale = min(proxy.size.width / 345, proxy.size.height / 285, 1.6)
            scene
                .frame(width: Self.canvasSize.width, height: Self.canvasSize.height)
                .scaleEffect(scale)
                .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }

    @ViewBuilder
    private var scene: some View {
        switch page {
        case .welcome: OnboardingCarouselWelcomeScene(features: features, isActive: isActive)
        case .setup(.calendar): OnboardingCarouselCalendarScene(isActive: isActive)
        case .setup(.reminders): OnboardingCarouselRemindersScene(isActive: isActive)
        case .setup(.alerts), .setup(.alarms): OnboardingCarouselAlertsScene(isActive: isActive)
        case .setup(.weather): OnboardingCarouselWeatherScene(isActive: isActive)
        case .setup(.sleep): OnboardingCarouselSleepScene(isActive: isActive)
        }
    }
}

extension View {
    func onboardingCarouselCard(cornerRadius: CGFloat = 20) -> some View {
        background(.thickMaterial, in: .rect(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(.white.opacity(0.3), lineWidth: 0.5)
            }
            .shadow(color: .black.opacity(0.14), radius: 16, y: 8)
    }
}
