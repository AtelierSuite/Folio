import Planner
import SwiftUI

struct TimelineEventCardText: View {
    let entry: TimelineEntry
    let timeDescription: String
    let presentation: TimelineCardPresentation
    let textMetrics: TimelineCardTextMetrics
    let compressesText: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: textMetrics.lineSpacing) {
            TimelineEntryTitleView(entry: entry)
                .font(.system(size: textMetrics.titlePointSize, weight: .semibold))
                .lineLimit(presentation.titleLineLimit)
                .horizontalTextFit(isEnabled: compressesText && presentation.titleLineLimit == 1)
            if presentation.detail >= .titleAndTime {
                Text(timeDescription)
                    .font(.system(size: textMetrics.detailPointSize))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .horizontalTextFit(isEnabled: compressesText)
            }
            if presentation.detail == .full, entry.location != nil || entry.hasLink {
                TimelineEventCardLocationRow(entry: entry)
                    .font(.system(size: textMetrics.detailPointSize))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .horizontalTextFit(isEnabled: compressesText)
            }
        }
    }
}
