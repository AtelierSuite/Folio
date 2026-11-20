import SwiftUI

struct OnboardingColorFieldsRemindersHero: View {
    private static let itemWidths: [CGFloat] = [64, 44, 54]

    var body: some View {
        OnboardingSequencePlayer(count: 4, interval: .milliseconds(650), hold: .seconds(2.2)) { progress in
            VStack(spacing: 28) {
                Image(systemName: "checklist")
                    .symbolEffect(.drawOn.byLayer, isActive: progress == 0)
                    .symbolEffect(.bounce, value: progress == 4)
                    .onboardingColorFieldsSymbol()
                items(checkedCount: max(progress - 1, 0))
            }
        }
    }

    private func items(checkedCount: Int) -> some View {
        HStack(spacing: 12) {
            ForEach(Array(Self.itemWidths.enumerated()), id: \.offset) { index, width in
                let isChecked = index < checkedCount
                HStack(spacing: 6) {
                    Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                        .contentTransition(.symbolEffect(.replace))
                        .font(.system(size: 15, weight: .bold))
                    Capsule()
                        .fill(.white.opacity(isChecked ? 0.45 : 0.9))
                        .frame(width: width, height: 6)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(.white.opacity(isChecked ? 0.1 : 0.2), in: .capsule)
            }
        }
    }
}
