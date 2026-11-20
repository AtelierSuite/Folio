import SwiftUI

struct OnboardingJourneyHero: View {
    let step: OnboardingSetupStep
    let isBadgeLanded: Bool
    let namespace: Namespace.ID

    var body: some View {
        illustration
            .id(step)
            .transition(.asymmetric(
                insertion: .scale(scale: 0.9).combined(with: .opacity),
                removal: .opacity
            ))
            .padding(.top, Metrics.badgeDiameter / 2 + 6)
            .padding([.horizontal, .bottom], Metrics.padding)
            .frame(maxWidth: .infinity)
            .frame(height: Metrics.height)
            .clipShape(cardShape)
            .background { card }
            .overlay(alignment: .top) {
                landingPad.offset(y: -Metrics.badgeDiameter / 2)
            }
            .padding(.top, Metrics.badgeDiameter / 2)
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private var illustration: some View {
        switch step {
        case .calendar: OnboardingJourneyCalendarHero()
        case .reminders: OnboardingJourneyRemindersHero()
        case .alerts, .alarms: OnboardingJourneyAlertsHero()
        case .weather: OnboardingJourneyWeatherHero()
        case .sleep: OnboardingJourneySleepHero()
        }
    }

    private var landingPad: some View {
        ZStack {
            Circle()
                .fill(.background)
                .overlay {
                    Circle().strokeBorder(tint.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
                }
            if isBadgeLanded {
                OnboardingJourneyBadge(step: step, state: .current)
                    .matchedGeometryEffect(id: step, in: namespace)
            }
        }
        .frame(width: Metrics.badgeDiameter, height: Metrics.badgeDiameter)
    }

    private var card: some View {
        cardShape
            .fill(.background)
            .overlay {
                cardShape.fill(LinearGradient(
                    colors: [tint.opacity(0.16), tint.opacity(0.04)],
                    startPoint: .top,
                    endPoint: .bottom
                ))
            }
            .overlay { cardShape.strokeBorder(tint.opacity(0.22), lineWidth: 1) }
            .shadow(color: tint.opacity(0.2), radius: 20, y: 10)
    }

    private var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Metrics.cornerRadius)
    }

    private var tint: Color {
        OnboardingJourneyPalette.tint(for: step)
    }

    private enum Metrics {
        #if os(macOS)
        static let height: CGFloat = 200
        static let padding: CGFloat = 16
        static let cornerRadius: CGFloat = 22
        static let badgeDiameter: CGFloat = 52
        #else
        static let height: CGFloat = 250
        static let padding: CGFloat = 20
        static let cornerRadius: CGFloat = 30
        static let badgeDiameter: CGFloat = 62
        #endif
    }
}
