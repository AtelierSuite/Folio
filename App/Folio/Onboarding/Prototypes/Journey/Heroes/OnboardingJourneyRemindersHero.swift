import SwiftUI

struct OnboardingJourneyRemindersHero: View {
    private static let lineWidths: [CGFloat] = [110, 80, 128, 94]
    private let tint = OnboardingJourneyPalette.tint(for: .reminders)

    var body: some View {
        OnboardingSequencePlayer(
            count: Self.lineWidths.count,
            interval: .milliseconds(700),
            hold: .seconds(2)
        ) { shownCount in
            HStack(spacing: Metrics.spacing) {
                ring(
                    progress: Double(shownCount) / Double(Self.lineWidths.count),
                    isComplete: shownCount == Self.lineWidths.count
                )
                VStack(alignment: .leading, spacing: Metrics.rowSpacing) {
                    ForEach(Array(Self.lineWidths.enumerated()), id: \.offset) { index, width in
                        row(isDone: index < shownCount, width: width)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func ring(progress: Double, isComplete: Bool) -> some View {
        ZStack {
            Circle()
                .stroke(tint.opacity(0.15), lineWidth: Metrics.ringWidth)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    OnboardingJourneyPalette.gradient(for: .reminders),
                    style: StrokeStyle(lineWidth: Metrics.ringWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            Image(systemName: isComplete ? "checkmark" : "checklist")
                .font(.system(size: Metrics.symbolSize, weight: .bold))
                .foregroundStyle(tint)
                .contentTransition(.symbolEffect(.replace))
        }
        .frame(width: Metrics.ringDiameter, height: Metrics.ringDiameter)
    }

    private func row(isDone: Bool, width: CGFloat) -> some View {
        HStack(spacing: 8) {
            Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                .font(.system(size: Metrics.checkSize, weight: .semibold))
                .foregroundStyle(isDone ? AnyShapeStyle(tint) : AnyShapeStyle(.secondary))
                .contentTransition(.symbolEffect(.replace))
            Capsule()
                .fill(.primary.opacity(isDone ? 0.15 : 0.5))
                .frame(width: width * Metrics.lineScale, height: 7)
        }
    }

    private enum Metrics {
        #if os(macOS)
        static let spacing: CGFloat = 24
        static let rowSpacing: CGFloat = 9
        static let ringDiameter: CGFloat = 92
        static let ringWidth: CGFloat = 12
        static let symbolSize: CGFloat = 24
        static let checkSize: CGFloat = 16
        static let lineScale: CGFloat = 0.85
        #else
        static let spacing: CGFloat = 28
        static let rowSpacing: CGFloat = 13
        static let ringDiameter: CGFloat = 116
        static let ringWidth: CGFloat = 15
        static let symbolSize: CGFloat = 30
        static let checkSize: CGFloat = 20
        static let lineScale: CGFloat = 1
        #endif
    }
}
