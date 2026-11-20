import SwiftUI

struct OnboardingJourneyPreview: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var drawProgress: Double = 0
    @State private var shownCount = 0
    @State private var isTravelling = false
    @State private var travelProgress: Double = 0
    let steps: [OnboardingSetupStep]
    let namespace: Namespace.ID
    var spacing: CGFloat = Metrics.spacing
    var badgeDiameter: CGFloat = Metrics.badgeDiameter
    var swing: CGFloat = 0.2

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                curve.stroke(.secondary.opacity(0.3), style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [2, 7]))
                curve
                    .trim(from: 0, to: drawProgress)
                    .stroke(
                        OnboardingJourneyPalette.pathGradient(for: steps, axis: .vertical),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                if isTravelling {
                    curve
                        .trim(from: max(0, travelProgress - 0.06), to: travelProgress)
                        .stroke(.white, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .shadow(color: .accentColor.opacity(0.9), radius: 6)
                }
                ForEach(Array(steps.enumerated()), id: \.element) { index, step in
                    OnboardingJourneyBadge(step: step, state: .preview)
                        .matchedGeometryEffect(id: step, in: namespace)
                        .frame(width: badgeDiameter, height: badgeDiameter)
                        .scaleEffect(index < shownCount ? 1 : 0.2)
                        .opacity(index < shownCount ? 1 : 0)
                        .position(
                            x: unitPoints[index].x * proxy.size.width,
                            y: unitPoints[index].y * proxy.size.height
                        )
                }
            }
        }
        .frame(height: CGFloat(steps.count) * spacing)
        .accessibilityHidden(true)
        .task { await play() }
    }

    private var curve: OnboardingJourneyCurve {
        OnboardingJourneyCurve(unitPoints: unitPoints, axis: .vertical)
    }

    private var unitPoints: [CGPoint] {
        steps.indices.map { index in
            CGPoint(
                x: 0.5 + (index.isMultiple(of: 2) ? -swing : swing),
                y: (CGFloat(index) + 0.5) / CGFloat(max(steps.count, 1))
            )
        }
    }

    private func play() async {
        guard !reducesMotion else {
            drawProgress = 1
            shownCount = steps.count
            return
        }
        let drawDuration = 0.45 * Double(max(steps.count - 1, 1))
        try? await Task.sleep(for: .milliseconds(500))
        withAnimation(.linear(duration: drawDuration)) { drawProgress = 1 }
        for index in steps.indices {
            withAnimation(.spring(duration: 0.5, bounce: 0.5)) { shownCount = index + 1 }
            try? await Task.sleep(for: .seconds(drawDuration / Double(max(steps.count - 1, 1))))
        }
        guard !Task.isCancelled, steps.count > 1 else { return }
        isTravelling = true
        withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: false)) { travelProgress = 1 }
    }

    enum Metrics {
        #if os(macOS)
        static let spacing: CGFloat = 54
        static let badgeDiameter: CGFloat = 36
        #else
        static let spacing: CGFloat = 60
        static let badgeDiameter: CGFloat = 44
        #endif
    }
}
