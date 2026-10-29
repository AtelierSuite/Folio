import Planner
import SwiftUI

struct TimelineReminderCardText: View {
    let entry: TimelineEntry
    let timeDescription: String
    let presentation: TimelineCardPresentation
    let textMetrics: TimelineCardTextMetrics
    let compressesText: Bool

    private var titleSize: CGFloat {
        textMetrics.titlePointSize * presentation.textScale
    }

    private var detailSize: CGFloat {
        textMetrics.detailPointSize * presentation.textScale
    }

    var body: some View {
        VStack(alignment: .leading, spacing: textMetrics.lineSpacing) {
            TimelineReminderTitleView(entry: entry)
                .font(.system(size: titleSize, weight: .semibold))
                .lineLimit(presentation.titleLineLimit)
                .minimumScaleFactor(minimumScaleFactor(for: titleSize))
            if presentation.detail >= .titleAndTime {
                Text(timeDescription)
                    .font(.system(size: detailSize))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(minimumScaleFactor(for: detailSize))
            }
        }
    }

    private func minimumScaleFactor(for pointSize: CGFloat) -> CGFloat {
        guard compressesText, pointSize > 0 else { return 1 }
        return min(1, textMetrics.minimumPointSize / pointSize)
    }
}
