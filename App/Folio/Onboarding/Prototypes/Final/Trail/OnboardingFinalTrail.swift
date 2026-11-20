import SwiftUI

struct OnboardingFinalTrail: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    let context: OnboardingPrototypeContext

    var body: some View {
        let steps = context.plannedSteps
        GeometryReader { proxy in
            let points = OnboardingFinalTrailLayout.points(count: steps.count, in: proxy.size)
            ZStack(alignment: .topLeading) {
                OnboardingFinalTrailLine(points: points)
                    .stroke(.white.opacity(0.35), style: StrokeStyle(lineWidth: 2.5, lineCap: .round, dash: [2, 7]))
                OnboardingFinalTrailLine(points: points)
                    .trim(from: 0, to: drawnFraction(stepCount: steps.count))
                    .stroke(.white, style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                    .shadow(color: .white.opacity(0.6), radius: 4)
                    .animation(reducesMotion ? nil : .easeInOut(duration: 0.9).delay(0.15), value: context.step)
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
        guard let currentIndex = context.currentIndex else { return .upcoming }
        if index < currentIndex { return .completed }
        return index == currentIndex ? .current : .upcoming
    }

    private func drawnFraction(stepCount: Int) -> Double {
        guard stepCount > 1, let currentIndex = context.currentIndex else { return 0 }
        return Double(currentIndex) / Double(stepCount - 1)
    }
}

enum OnboardingFinalTrailLayout {
    #if os(macOS)
    static let height: CGFloat = 58
    #else
    static let height: CGFloat = 70
    #endif
    static let inset: CGFloat = 30

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
