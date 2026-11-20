import SwiftUI

struct OnboardingJourneyAlertsHero: View {
    private let tint = OnboardingJourneyPalette.tint(for: .alerts)

    var body: some View {
        OnboardingSequencePlayer(count: 2, interval: .milliseconds(750), hold: .seconds(2.4)) { shownCount in
            VStack(spacing: Metrics.spacing) {
                banner
                    .offset(y: shownCount > 1 ? 0 : -Metrics.bannerHeight * 2)
                    .opacity(shownCount > 1 ? 1 : 0)
                    .zIndex(1)
                bell(isRinging: shownCount > 0, shownCount: shownCount)
                    .frame(maxHeight: .infinity)
            }
        }
    }

    private func bell(isRinging: Bool, shownCount: Int) -> some View {
        ZStack {
            ForEach(0..<3, id: \.self) { ring in
                Circle()
                    .stroke(tint.opacity(0.55 - Double(ring) * 0.15), lineWidth: 2)
                    .frame(width: Metrics.bellCircle, height: Metrics.bellCircle)
                    .scaleEffect(isRinging ? 1.25 + Double(ring) * 0.4 : 0.8)
                    .opacity(isRinging ? 1 : 0)
                    .animation(.easeOut(duration: 0.9).delay(Double(ring) * 0.12), value: isRinging)
            }
            Circle()
                .fill(OnboardingJourneyPalette.gradient(for: .alerts))
                .frame(width: Metrics.bellCircle, height: Metrics.bellCircle)
                .shadow(color: tint.opacity(0.45), radius: 10, y: 5)
            Image(systemName: "bell.fill")
                .font(.system(size: Metrics.bellSymbol, weight: .semibold))
                .foregroundStyle(.white)
                .symbolEffect(.wiggle, value: shownCount)
        }
    }

    private var banner: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 8)
                .fill(OnboardingJourneyPalette.gradient(for: .alerts))
                .frame(width: 30, height: 30)
                .overlay {
                    Image(systemName: "calendar")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                }
            VStack(alignment: .leading, spacing: 6) {
                Capsule().fill(.primary.opacity(0.7)).frame(width: 96, height: 6)
                Capsule().fill(.secondary.opacity(0.5)).frame(width: 140, height: 5)
            }
            Spacer(minLength: 0)
            Capsule().fill(.secondary.opacity(0.4)).frame(width: 22, height: 5)
        }
        .padding(.horizontal, 12)
        .frame(height: Metrics.bannerHeight)
        .background(.regularMaterial, in: .rect(cornerRadius: 16))
        .shadow(color: .black.opacity(0.14), radius: 10, y: 4)
    }

    private enum Metrics {
        #if os(macOS)
        static let spacing: CGFloat = 8
        static let bannerHeight: CGFloat = 46
        static let bellCircle: CGFloat = 54
        static let bellSymbol: CGFloat = 24
        #else
        static let spacing: CGFloat = 12
        static let bannerHeight: CGFloat = 54
        static let bellCircle: CGFloat = 66
        static let bellSymbol: CGFloat = 30
        #endif
    }
}
