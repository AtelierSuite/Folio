import SwiftUI

struct OnboardingLiquidGlassTimeline {
    static let hourCount = 4
    let size: CGSize

    var leadingInset: CGFloat { 40 }
    var trailingInset: CGFloat { 8 }
    var topInset: CGFloat { 14 }
    var hourHeight: CGFloat { (size.height - topInset * 2) / CGFloat(Self.hourCount) }

    func yPosition(forHour hour: Double) -> CGFloat {
        topInset + hourHeight * hour
    }

    func frame(start: Double, duration: Double, lane: Int = 0, laneCount: Int = 1) -> CGRect {
        let gap: CGFloat = 6
        let laneWidth = (size.width - leadingInset - trailingInset - gap * CGFloat(laneCount - 1)) / CGFloat(laneCount)
        return CGRect(
            x: leadingInset + (laneWidth + gap) * CGFloat(lane),
            y: yPosition(forHour: start) + 2,
            width: laneWidth,
            height: hourHeight * duration - 4
        )
    }
}

struct OnboardingLiquidGlassHourGrid: View {
    let timeline: OnboardingLiquidGlassTimeline
    let showsNow: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(0...OnboardingLiquidGlassTimeline.hourCount, id: \.self) { hour in
                HStack(spacing: 8) {
                    Capsule()
                        .fill(.secondary.opacity(0.5))
                        .frame(width: 20, height: 5)
                    Rectangle()
                        .fill(.secondary.opacity(0.25))
                        .frame(height: 1)
                }
                .padding(.leading, 6)
                .offset(y: timeline.yPosition(forHour: Double(hour)) - 2.5)
            }
            HStack(spacing: 0) {
                Circle()
                    .fill(.red)
                    .frame(width: 8, height: 8)
                Rectangle()
                    .fill(.red)
                    .frame(height: 2)
            }
            .padding(.leading, timeline.leadingInset - 4)
            .offset(y: timeline.yPosition(forHour: 1.3) - 4)
            .opacity(showsNow ? 1 : 0)
        }
        .frame(width: timeline.size.width, height: timeline.size.height, alignment: .topLeading)
    }
}
