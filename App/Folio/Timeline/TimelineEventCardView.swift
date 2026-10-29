import Planner
import SwiftUI

struct TimelineEventCardView: View {
    let placement: TimelineTimedPlacement
    let timeZone: TimeZone
    let presentation: TimelineCardPresentation
    let textMetrics: TimelineCardTextMetrics
    let compressesText: Bool

    private var entry: TimelineEntry {
        placement.entry
    }

    private var shape: UnevenRoundedRectangle {
        let topRadius: CGFloat = placement.continuesFromPreviousDay ? 0 : 5
        let bottomRadius: CGFloat = placement.continuesToNextDay ? 0 : 5
        return UnevenRoundedRectangle(
            topLeadingRadius: topRadius,
            bottomLeadingRadius: bottomRadius,
            bottomTrailingRadius: bottomRadius,
            topTrailingRadius: topRadius
        )
    }

    var body: some View {
        let color = Color(entry.color)
        Group {
            if presentation.detail == .bar {
                shape.fill(color.opacity(0.85))
            } else {
                TimelineEventCardText(
                    entry: entry,
                    timeDescription: timeDescription,
                    presentation: presentation,
                    textMetrics: textMetrics,
                    compressesText: compressesText
                )
                .padding(.leading, 6)
                .padding(.trailing, 3)
                .padding(.vertical, presentation.showsPadding ? textMetrics.verticalPadding / 2 : 0)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(color.opacity(0.22), in: shape)
                .overlay(alignment: .leading) {
                    Rectangle()
                        .fill(color)
                        .frame(width: 3)
                }
                .clipShape(shape)
            }
        }
        .padding(1)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityTitle)
        .accessibilityValue([timeDescription, entry.location].compactMap { $0 }.joined(separator: ", "))
    }

    private var accessibilityTitle: String {
        guard entry.kind == .reminder else { return entry.title }
        return "\(String(localized: "Accessibility.Reminder", table: "Timeline")), \(entry.title)"
    }

    private var timeDescription: String {
        let style = Date.FormatStyle(date: .omitted, time: .shortened, timeZone: timeZone)
        guard entry.kind == .event else { return placement.interval.start.formatted(style) }
        return "\(placement.interval.start.formatted(style)) – \(placement.interval.end.formatted(style))"
    }
}
