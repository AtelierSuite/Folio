import SwiftUI

struct OnboardingCarouselAlertsScene: View {
    let isActive: Bool

    private static let eventFrame = CGRect(x: 92, y: 160, width: 196, height: 72)
    private static let bannerFrame = CGRect(x: 10, y: 22, width: 300, height: 64)

    var body: some View {
        OnboardingCarouselLoop(
            isActive: isActive,
            count: 3,
            interval: .milliseconds(750),
            hold: .seconds(2.4)
        ) { phase in
            ZStack(alignment: .topLeading) {
                OnboardingCarouselHourGrid()
                    .frame(width: 280, height: 196)
                    .offset(x: 20, y: 52)
                    .offset(y: phase > 2 ? 6 : 0)
                OnboardingCarouselAlertEvent()
                    .frame(width: Self.eventFrame.width, height: Self.eventFrame.height)
                    .scaleEffect(phase > 0 ? 1 : 0.85, anchor: .top)
                    .opacity(phase > 0 ? 1 : 0)
                    .offset(x: Self.eventFrame.minX, y: Self.eventFrame.minY + (phase > 2 ? 6 : 0))
                OnboardingCarouselLeadLine()
                    .frame(width: 2, height: Self.eventFrame.minY - Self.bannerFrame.maxY)
                    .scaleEffect(y: phase > 1 ? 1 : 0, anchor: .bottom)
                    .offset(x: Self.eventFrame.minX + 28, y: Self.bannerFrame.maxY)
                OnboardingCarouselAlertBanner(isRinging: phase > 2)
                    .frame(width: Self.bannerFrame.width, height: Self.bannerFrame.height)
                    .scaleEffect(phase > 2 ? 1 : 0.92)
                    .opacity(phase > 2 ? 1 : 0)
                    .offset(x: Self.bannerFrame.minX, y: phase > 2 ? Self.bannerFrame.minY : -80)
            }
            .frame(width: 320, height: 260, alignment: .topLeading)
        }
    }
}

private struct OnboardingCarouselHourGrid: View {
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<5, id: \.self) { _ in
                HStack(spacing: 10) {
                    Capsule()
                        .fill(.secondary.opacity(0.4))
                        .frame(width: 22, height: 5)
                    Rectangle()
                        .fill(.primary.opacity(0.08))
                        .frame(height: 1)
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 16)
        .onboardingCarouselCard()
    }
}

private struct OnboardingCarouselAlertEvent: View {
    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(.red)
                .frame(width: 4)
            VStack(alignment: .leading, spacing: 6) {
                Capsule()
                    .fill(.white.opacity(0.95))
                    .frame(width: 96, height: 7)
                Capsule()
                    .fill(.white.opacity(0.6))
                    .frame(width: 60, height: 5)
            }
            .padding(.leading, 10)
            Spacer(minLength: 0)
        }
        .background(
            LinearGradient(colors: [.orange, .red.opacity(0.85)], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: .rect(cornerRadius: 10, style: .continuous)
        )
        .clipShape(.rect(cornerRadius: 10, style: .continuous))
        .shadow(color: .red.opacity(0.3), radius: 8, y: 4)
    }
}

private struct OnboardingCarouselLeadLine: View {
    var body: some View {
        Rectangle()
            .stroke(.red.opacity(0.8), style: StrokeStyle(lineWidth: 2, dash: [3, 4]))
    }
}

private struct OnboardingCarouselAlertBanner: View {
    let isRinging: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 18, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.white)
                .symbolEffect(.wiggle, value: isRinging)
                .frame(width: 38, height: 38)
                .background(
                    LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom),
                    in: .rect(cornerRadius: 10, style: .continuous)
                )
            VStack(alignment: .leading, spacing: 6) {
                Capsule()
                    .fill(.primary.opacity(0.7))
                    .frame(width: 110, height: 7)
                Capsule()
                    .fill(.secondary.opacity(0.45))
                    .frame(width: 160, height: 5)
            }
            Spacer(minLength: 0)
            Capsule()
                .fill(.secondary.opacity(0.35))
                .frame(width: 26, height: 5)
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.top, 16)
        }
        .padding(.horizontal, 12)
        .background(.regularMaterial, in: .rect(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(.white.opacity(0.35), lineWidth: 0.5)
        }
        .shadow(color: .black.opacity(0.22), radius: 18, y: 10)
    }
}
