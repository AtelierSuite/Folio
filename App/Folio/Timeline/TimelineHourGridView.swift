import SwiftUI

/// Drawn in bands of a few hours: a page inside the horizontal scroll view is rendered on its own,
/// and one canvas the height of a fully zoomed in day is too tall to draw, so it would stay blank.
struct TimelineHourGridView: View {
    let dayCount: Int
    let hourHeight: CGFloat

    private static let hoursPerBand = 6

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(stride(from: 0, to: 24, by: Self.hoursPerBand)), id: \.self) { firstHour in
                TimelineHourGridBand(
                    dayCount: dayCount,
                    hourHeight: hourHeight,
                    hourCount: min(Self.hoursPerBand, 24 - firstHour)
                )
                .frame(height: hourHeight * CGFloat(min(Self.hoursPerBand, 24 - firstHour)))
            }
        }
        .accessibilityHidden(true)
    }
}

/// Each band draws both of its edges, so the lines where bands meet are as wide as the others.
private struct TimelineHourGridBand: View {
    let dayCount: Int
    let hourHeight: CGFloat
    let hourCount: Int

    var body: some View {
        Canvas { context, size in
            var hourLines = Path()
            var halfHourLines = Path()
            for hour in 0...hourCount {
                let yPosition = CGFloat(hour) * hourHeight
                hourLines.move(to: CGPoint(x: 0, y: yPosition))
                hourLines.addLine(to: CGPoint(x: size.width, y: yPosition))
                guard hour < hourCount else { continue }
                halfHourLines.move(to: CGPoint(x: 0, y: yPosition + hourHeight / 2))
                halfHourLines.addLine(to: CGPoint(x: size.width, y: yPosition + hourHeight / 2))
            }
            let dayWidth = size.width / CGFloat(max(dayCount, 1))
            for dayIndex in 0...dayCount {
                hourLines.move(to: CGPoint(x: CGFloat(dayIndex) * dayWidth, y: 0))
                hourLines.addLine(to: CGPoint(x: CGFloat(dayIndex) * dayWidth, y: size.height))
            }
            context.stroke(hourLines, with: .style(.separator), lineWidth: 0.5)
            if hourHeight >= 40 {
                context.stroke(halfHourLines, with: .style(.separator.opacity(0.4)), lineWidth: 0.5)
            }
        }
    }
}
