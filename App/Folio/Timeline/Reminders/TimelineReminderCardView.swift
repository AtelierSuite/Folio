import Planner
import SwiftUI

/// A timed reminder: the checkbox toggles it, the rest of the card opens it.
struct TimelineReminderCardView: View {
    let placement: TimelineTimedPlacement
    let timeZone: TimeZone
    let presentation: TimelineCardPresentation
    let textMetrics: TimelineCardTextMetrics
    let compressesText: Bool
    var onSelect: ((TimelineEntry) -> Void)?

    private var entry: TimelineEntry {
        placement.entry
    }

    private var titleSize: CGFloat {
        textMetrics.titlePointSize * presentation.textScale
    }

    private let shape = RoundedRectangle(cornerRadius: 5)

    var body: some View {
        let color = Color(entry.color)
        Group {
            if presentation.detail == .bar {
                shape.fill(color.opacity(entry.isCompleted ? 0.4 : 0.85))
                    .timelineEntrySelection(entry, onSelect: onSelect)
                    .accessibilityLabel(entry.title)
            } else {
                HStack(alignment: .top, spacing: 2) {
                    TimelineReminderCheckbox(entry: entry)
                        .font(.system(size: titleSize))
                    TimelineReminderCardText(
                        entry: entry,
                        timeDescription: timeDescription,
                        presentation: presentation,
                        textMetrics: textMetrics,
                        compressesText: compressesText
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .contentShape(.rect)
                    .timelineEntrySelection(entry, onSelect: onSelect)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(entry.title)
                    .accessibilityValue(timeDescription)
                    .accessibilityHint(String(localized: "Card.OpenHint", table: "Reminders"))
                }
                .padding(.leading, 5)
                .padding(.trailing, 3)
                .padding(.vertical, presentation.showsPadding ? textMetrics.verticalPadding / 2 : 0)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(color.opacity(entry.isCompleted ? 0.1 : 0.22), in: shape)
                .overlay(alignment: .leading) {
                    Rectangle()
                        .fill(color)
                        .frame(width: 3)
                }
                .clipShape(shape)
            }
        }
        .padding(1)
    }

    private var timeDescription: String {
        placement.interval.start.formatted(Date.FormatStyle(date: .omitted, time: .shortened, timeZone: timeZone))
    }
}
