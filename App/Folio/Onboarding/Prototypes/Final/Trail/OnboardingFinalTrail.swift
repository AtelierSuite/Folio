import SwiftUI

struct OnboardingFinalTrail: View {
    let steps: [OnboardingSetupStep]
    let stage: OnboardingFinalStage

    var body: some View {
        GeometryReader { proxy in
            let points = OnboardingFinalTrailLayout.points(count: steps.count, in: proxy.size)
            ZStack(alignment: .topLeading) {
                OnboardingFinalTrailLine(points: points)
                    .stroke(.white.opacity(0.35), style: StrokeStyle(lineWidth: 2.5, lineCap: .round, dash: [2, 7]))
                OnboardingFinalTrailLine(points: points)
                    .trim(from: 0, to: drawnFraction)
                    .stroke(.white, style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                    .shadow(color: .white.opacity(0.6), radius: 4)
                ForEach(Array(steps.enumerated()), id: \.element) { index, step in
                    OnboardingFinalBadge(step: step, state: state(at: index))
                        .onboardingEntrance(delay: 0.1 + Double(index) * 0.08)
                        .position(points[index])
                }
            }
        }
        .frame(height: OnboardingFinalTrailLayout.height)
        .accessibilityHidden(true)
    }

    private func state(at index: Int) -> OnboardingFinalBadgeState {
        if index < stage.completedCount {
            return stage.declinedSteps.contains(steps[index]) ? .declined : .completed
        }
        return index == stage.highlightedIndex ? .current : .upcoming
    }

    private var drawnFraction: Double {
        guard steps.count > 1, let lineIndex = stage.lineIndex else { return 0 }
        return Double(lineIndex) / Double(steps.count - 1)
    }
}

enum OnboardingFinalTrailLayout {
    #if os(macOS)
    static let height: CGFloat = 58
    #else
    static let height: CGFloat = 70
    #endif
    static let inset: CGFloat = 30
    static let spacing: CGFloat = 12

    static func badgeCenter(
        for step: OnboardingSetupStep,
        in steps: [OnboardingSetupStep],
        width: CGFloat
    ) -> CGPoint? {
        guard let index = steps.firstIndex(of: step) else { return nil }
        let point = points(count: steps.count, in: CGSize(width: width, height: height))[index]
        return CGPoint(x: point.x, y: point.y - height - spacing)
    }

    static func points(count: Int, in size: CGSize) -> [CGPoint] {
        guard count > 1 else {
            return count == 1 ? [CGPoint(x: size.width / 2, y: size.height / 2)] : []
        }
        let stride = (size.width - inset * 2) / CGFloat(count - 1)
        return (0..<count).map { index in
            CGPoint(x: inset + stride * CGFloat(index), y: size.height / 2)
        }
    }
}

nonisolated struct OnboardingFinalTrailLine: Shape {
    var points: [CGPoint]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard let first = points.first else { return path }
        path.move(to: first)
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        return path
    }
}
