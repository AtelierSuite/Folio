import SwiftUI

struct OnboardingColorFieldsSleepHero: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    private static let stars: [OnboardingColorFieldsStar] = [
        .init(offset: CGSize(width: -104, height: -64), size: 14),
        .init(offset: CGSize(width: 96, height: -78), size: 10),
        .init(offset: CGSize(width: 118, height: 8), size: 12),
        .init(offset: CGSize(width: -120, height: 22), size: 9),
        .init(offset: CGSize(width: -64, height: -104), size: 8)
    ]
    private static let eventWidths: [CGFloat] = [26, 40, 22]

    var body: some View {
        OnboardingSequencePlayer(count: 4, interval: .milliseconds(600), hold: .seconds(2.4)) { progress in
            VStack(spacing: 28) {
                ZStack {
                    ForEach(Array(Self.stars.enumerated()), id: \.offset) { index, star in
                        Image(systemName: "sparkle")
                            .font(.system(size: star.size, weight: .bold))
                            .symbolEffect(
                                .breathe.pulse,
                                options: .repeat(.periodic(delay: Double(index) * 0.3)),
                                isActive: !reducesMotion
                            )
                            .opacity(0.75)
                            .offset(star.offset)
                    }
                    Image(systemName: "moon.zzz.fill")
                        .symbolEffect(.breathe.plain.byLayer, isActive: !reducesMotion)
                        .onboardingColorFieldsSymbol()
                }
                day(progress: progress)
            }
        }
    }

    private func day(progress: Int) -> some View {
        HStack(spacing: 8) {
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.white.opacity(0.2))
                Capsule()
                    .fill(.white.opacity(0.55))
                    .frame(width: progress >= 1 ? 96 : 0)
                Image(systemName: "bed.double.fill")
                    .font(.system(size: 11, weight: .bold))
                    .padding(.leading, 8)
                    .opacity(progress >= 1 ? 1 : 0)
            }
            .frame(width: 96, height: 22)
            ForEach(Array(Self.eventWidths.enumerated()), id: \.offset) { index, width in
                let isShown = progress >= index + 2
                Capsule()
                    .fill(.white)
                    .frame(width: width, height: 22)
                    .opacity(isShown ? 1 : 0)
                    .scaleEffect(isShown ? 1 : 0.5, anchor: .leading)
            }
        }
        .frame(width: 220, alignment: .leading)
    }
}

private struct OnboardingColorFieldsStar {
    let offset: CGSize
    let size: CGFloat
}
