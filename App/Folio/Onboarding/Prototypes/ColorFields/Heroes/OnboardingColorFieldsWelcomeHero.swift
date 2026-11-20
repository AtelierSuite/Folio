import SwiftUI

struct OnboardingColorFieldsWelcomeHero: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var featureIndex = 0
    let features: [OnboardingFeature]

    var body: some View {
        ZStack {
            OnboardingColorFieldsOrbit(count: features.count, highlightedIndex: featureIndex)
            Image(systemName: currentFeature?.systemImage ?? "calendar")
                .contentTransition(.symbolEffect(.replace.magic(fallback: .downUp.byLayer)))
                .onboardingColorFieldsSymbol()
        }
        .task(id: reducesMotion) { await cycle() }
    }

    private var currentFeature: OnboardingFeature? {
        features.indices.contains(featureIndex) ? features[featureIndex] : features.first
    }

    private func cycle() async {
        featureIndex = 0
        guard !reducesMotion, !features.isEmpty else { return }
        while !Task.isCancelled {
            try? await Task.sleep(for: .seconds(2.2))
            withAnimation(.spring(duration: 0.6, bounce: 0.3)) {
                featureIndex = (featureIndex + 1) % features.count
            }
        }
    }
}

private struct OnboardingColorFieldsOrbit: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    let count: Int
    let highlightedIndex: Int

    var body: some View {
        TimelineView(.animation(paused: reducesMotion)) { timeline in
            let rotation = reducesMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate
                .truncatingRemainder(dividingBy: 3600) * 0.25
            ZStack {
                Circle()
                    .strokeBorder(.white.opacity(0.18), style: StrokeStyle(lineWidth: 1, dash: [2, 6]))
                    .frame(width: Metrics.radius * 2, height: Metrics.radius * 2)
                ForEach(0..<count, id: \.self) { index in
                    let angle = rotation + Double(index) / Double(max(count, 1)) * 2 * .pi
                    Circle()
                        .fill(.white.opacity(index == highlightedIndex ? 1 : 0.45))
                        .frame(width: dotSize(for: index), height: dotSize(for: index))
                        .shadow(color: .white.opacity(index == highlightedIndex ? 0.8 : 0), radius: 8)
                        .offset(x: cos(angle) * Metrics.radius, y: sin(angle) * Metrics.radius)
                }
            }
        }
    }

    private func dotSize(for index: Int) -> CGFloat {
        index == highlightedIndex ? 14 : 8
    }

    private enum Metrics {
        #if os(macOS)
        static let radius: CGFloat = 96
        #else
        static let radius: CGFloat = 124
        #endif
    }
}
