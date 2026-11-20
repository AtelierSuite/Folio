import SwiftUI

struct OnboardingJourneyTrail: View {
    let steps: [OnboardingSetupStep]
    let currentStep: OnboardingSetupStep
    let isCurrentLanded: Bool
    let segmentProgress: Double
    let namespace: Namespace.ID

    var body: some View {
        GeometryReader { proxy in
            let unitPoints = unitPoints(in: proxy.size)
            let curve = OnboardingJourneyCurve(unitPoints: unitPoints, axis: .horizontal)
            ZStack {
                curve.stroke(.secondary.opacity(0.3), style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [2, 7]))
                curve
                    .trim(from: 0, to: drawnFraction)
                    .stroke(
                        OnboardingJourneyPalette.pathGradient(for: steps, axis: .horizontal),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                ForEach(Array(steps.enumerated()), id: \.element) { index, step in
                    milestone(for: step, at: index)
                        .position(
                            x: unitPoints[index].x * proxy.size.width,
                            y: unitPoints[index].y * proxy.size.height
                        )
                }
            }
        }
        .frame(height: Metrics.height)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private func milestone(for step: OnboardingSetupStep, at index: Int) -> some View {
        if step == currentStep {
            ZStack {
                OnboardingJourneyPulseRing(tint: OnboardingJourneyPalette.tint(for: step))
                    .frame(width: Metrics.ringDiameter, height: Metrics.ringDiameter)
                if isCurrentLanded {
                    Image(systemName: OnboardingJourneyPalette.symbol(for: step))
                        .font(.system(size: Metrics.ghostSymbolSize, weight: .semibold))
                        .foregroundStyle(OnboardingJourneyPalette.tint(for: step).opacity(0.45))
                        .transition(.opacity)
                } else {
                    OnboardingJourneyBadge(step: step, state: .current)
                        .matchedGeometryEffect(id: step, in: namespace)
                        .frame(width: Metrics.currentDiameter, height: Metrics.currentDiameter)
                }
            }
        } else {
            OnboardingJourneyBadge(step: step, state: index < currentIndex ? .completed : .upcoming)
                .matchedGeometryEffect(id: step, in: namespace)
                .frame(width: Metrics.badgeDiameter, height: Metrics.badgeDiameter)
        }
    }

    private var currentIndex: Int {
        steps.firstIndex(of: currentStep) ?? 0
    }

    private var drawnFraction: Double {
        guard steps.count > 1 else { return 0 }
        let travelled = Double(currentIndex - 1) + segmentProgress
        return min(max(travelled / Double(steps.count - 1), 0), 1)
    }

    private func unitPoints(in size: CGSize) -> [CGPoint] {
        guard steps.count > 1, size.width > 0, size.height > 0 else {
            return [CGPoint(x: 0.5, y: 0.5)]
        }
        let inset = Metrics.ringDiameter / 2 + 4
        let stride = (size.width - inset * 2) / CGFloat(steps.count - 1)
        return steps.indices.map { index in
            let waveOffset = (index.isMultiple(of: 2) ? -Metrics.wave : Metrics.wave) / size.height
            return CGPoint(x: (inset + stride * CGFloat(index)) / size.width, y: 0.5 + waveOffset)
        }
    }

    private enum Metrics {
        #if os(macOS)
        static let height: CGFloat = 64
        static let ringDiameter: CGFloat = 50
        static let currentDiameter: CGFloat = 40
        static let badgeDiameter: CGFloat = 30
        static let ghostSymbolSize: CGFloat = 16
        static let wave: CGFloat = 7
        #else
        static let height: CGFloat = 76
        static let ringDiameter: CGFloat = 58
        static let currentDiameter: CGFloat = 46
        static let badgeDiameter: CGFloat = 34
        static let ghostSymbolSize: CGFloat = 19
        static let wave: CGFloat = 9
        #endif
    }
}
