import SwiftUI

struct OnboardingTimeline<Content: View>: View {
    var hourCount = 4
    @ViewBuilder let content: (OnboardingTimelineMetrics) -> Content

    var body: some View {
        GeometryReader { proxy in
            let metrics = OnboardingTimelineMetrics(size: proxy.size, hourCount: hourCount)
            ZStack(alignment: .topLeading) {
                OnboardingTimelineHours(metrics: metrics)
                content(metrics)
            }
        }
    }
}

private struct OnboardingTimelineHours: View {
    let metrics: OnboardingTimelineMetrics

    var body: some View {
        ForEach(0..<metrics.hourCount, id: \.self) { hour in
            HStack(spacing: 6) {
                Capsule()
                    .fill(.quaternary)
                    .frame(width: 18, height: 5)
                Rectangle()
                    .fill(.quaternary.opacity(0.6))
                    .frame(height: 1)
            }
            .frame(width: metrics.size.width)
            .offset(y: metrics.y(at: Double(hour)) - 2.5)
        }
    }
}
