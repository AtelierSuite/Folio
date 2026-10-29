import Planner
import SwiftUI

struct TimelineCardsView: View {
    let layout: TimelineLayout
    let hourHeight: CGFloat
    let minimumCardHeight: CGFloat
    var onSelectEntry: ((TimelineEntry) -> Void)?
    @AppStorage(TimelineSettings.compressesTextKey) private var compressesText = false
    @ScaledMetric(relativeTo: .caption) private var titlePointSize = TimelineMetrics.cardTitlePointSize
    @ScaledMetric(relativeTo: .caption2) private var detailPointSize = TimelineMetrics.cardDetailPointSize
    @State private var width: CGFloat = 0

    /// The card's own `padding(1)` on each side.
    private let cardInset: CGFloat = 2

    var body: some View {
        let resolver = TimelineCardDetailResolver(
            metrics: TimelineCardTextMetrics(titlePointSize: titlePointSize, detailPointSize: detailPointSize),
            compressesText: compressesText
        )
        let dayWidth = width / CGFloat(max(layout.days.count, 1))
        TimelineSlotLayout(dayCount: layout.days.count, hourHeight: hourHeight, minimumHeight: minimumCardHeight) {
            ForEach(layout.timedPlacements) { placement in
                let slot = TimelineSlot(placement)
                let size = CGSize(
                    width: dayWidth * slot.widthFraction - cardInset,
                    height: slot.height(hourHeight: hourHeight, minimumHeight: minimumCardHeight) - cardInset
                )
                TimelineEventCardView(
                    placement: placement,
                    timeZone: layout.days.calendar.timeZone,
                    presentation: resolver.presentation(for: size),
                    textMetrics: resolver.metrics,
                    compressesText: compressesText
                )
                .timelineEntrySelection(placement.entry, onSelect: onSelectEntry)
                .timelineSlot(slot)
            }
        }
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width = $0 }
    }
}
