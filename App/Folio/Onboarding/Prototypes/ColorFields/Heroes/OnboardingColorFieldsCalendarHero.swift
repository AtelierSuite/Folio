import SwiftUI

struct OnboardingColorFieldsCalendarHero: View {
    private static let eventHeights: [Int: CGFloat] = [1: 22, 2: 12, 4: 28, 5: 16]
    private static let dayCount = 7

    var body: some View {
        OnboardingSequencePlayer(count: Self.dayCount, interval: .milliseconds(380), hold: .seconds(2.4)) { litCount in
            VStack(spacing: 26) {
                Image(systemName: "calendar")
                    .symbolEffect(.bounce.up.byLayer, value: litCount)
                    .onboardingColorFieldsSymbol()
                week(litCount: litCount)
            }
        }
    }

    private func week(litCount: Int) -> some View {
        HStack(alignment: .bottom, spacing: 14) {
            ForEach(0..<Self.dayCount, id: \.self) { day in
                let isLit = day < litCount
                VStack(spacing: 6) {
                    if let height = Self.eventHeights[day] {
                        Capsule()
                            .fill(.white.opacity(isLit ? 0.9 : 0))
                            .frame(width: 8, height: isLit ? height : 0)
                    }
                    Circle()
                        .fill(.white.opacity(isLit ? 1 : 0.3))
                        .frame(width: 10, height: 10)
                        .scaleEffect(isLit ? 1.15 : 1)
                }
                .frame(height: 44, alignment: .bottom)
            }
        }
    }
}
