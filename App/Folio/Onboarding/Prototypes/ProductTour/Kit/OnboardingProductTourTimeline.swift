import SwiftUI

struct OnboardingProductTourTimelineMetrics {
    let width: CGFloat
    let hourHeight: CGFloat
    let firstHour: Int

    var gutterWidth: CGFloat { min(max(width * 0.2, 30), 44) }

    func y(for hour: Double) -> CGFloat {
        (hour - Double(firstHour)) * hourHeight
    }

    func frame(for event: OnboardingProductTourEvent) -> CGRect {
        let laneWidth = (width - gutterWidth - 6) / CGFloat(event.laneCount)
        return CGRect(
            x: gutterWidth + laneWidth * CGFloat(event.lane),
            y: y(for: event.start) + 1,
            width: laneWidth - 3,
            height: event.duration * hourHeight - 2
        )
    }
}

struct OnboardingProductTourEvent {
    let start: Double
    let duration: Double
    var lane = 0
    var laneCount = 1
    let color: Color
}

struct OnboardingProductTourTimeline<Content: View>: View {
    let metrics: OnboardingProductTourTimelineMetrics
    let lastHour: Int
    let topHour: Double
    @ViewBuilder let content: Content

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(metrics.firstHour...lastHour, id: \.self) { hour in
                OnboardingProductTourHourLine(metrics: metrics, hour: hour)
            }
            content
        }
        .frame(width: metrics.width, height: metrics.y(for: Double(lastHour + 1)), alignment: .topLeading)
        .offset(y: -metrics.y(for: topHour))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .clipped()
    }
}

private struct OnboardingProductTourHourLine: View {
    let metrics: OnboardingProductTourTimelineMetrics
    let hour: Int

    var body: some View {
        let lineY = metrics.y(for: Double(hour))
        let labelWidth = metrics.gutterWidth * 0.42
        ZStack(alignment: .topLeading) {
            Capsule()
                .fill(Color.secondary.opacity(0.45))
                .frame(width: labelWidth, height: 3)
                .position(x: 6 + labelWidth / 2, y: lineY)
            Rectangle()
                .fill(Color.primary.opacity(0.08))
                .frame(width: metrics.width - metrics.gutterWidth, height: 0.5)
                .position(x: metrics.gutterWidth + (metrics.width - metrics.gutterWidth) / 2, y: lineY)
        }
    }
}

struct OnboardingProductTourNowLine: View {
    let metrics: OnboardingProductTourTimelineMetrics
    let hour: Double

    var body: some View {
        let lineY = metrics.y(for: hour)
        ZStack(alignment: .topLeading) {
            Rectangle()
                .fill(Color.red)
                .frame(width: metrics.width - metrics.gutterWidth, height: 1.2)
                .position(x: metrics.gutterWidth + (metrics.width - metrics.gutterWidth) / 2, y: lineY)
            Circle()
                .fill(Color.red)
                .frame(width: 6, height: 6)
                .position(x: metrics.gutterWidth, y: lineY)
        }
    }
}

extension View {
    func onboardingProductTourPlaced(in rect: CGRect) -> some View {
        frame(width: max(rect.width, 0), height: max(rect.height, 0))
            .position(x: rect.midX, y: rect.midY)
    }
}
