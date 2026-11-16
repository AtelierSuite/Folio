import CoreGraphics

/// Picks how much an event card shows for its size: title, time, location and link icon, then
/// title and time, then the title, then just a colored bar. With `compressesText` the text
/// narrows (down to `minimumHorizontalTextScale`) to fit the card's width instead of being cut off.
public struct TimelineCardDetailResolver: Sendable, Equatable {
    public var metrics: TimelineCardTextMetrics
    public var compressesText: Bool

    public init(metrics: TimelineCardTextMetrics, compressesText: Bool) {
        self.metrics = metrics
        self.compressesText = compressesText
    }

    public func presentation(for size: CGSize) -> TimelineCardPresentation {
        guard size.width >= minimumWidth else { return .bar }
        for detail in TimelineCardDetail.allCases.reversed() where detail != .bar {
            guard size.height >= requiredHeight(for: detail, padded: false) else { continue }
            return TimelineCardPresentation(
                detail: detail,
                titleLineLimit: titleLineLimit(for: detail, height: size.height),
                showsPadding: detail != .title || size.height >= requiredHeight(for: .title)
            )
        }
        return .bar
    }

    public var minimumWidth: CGFloat {
        let horizontalScale = compressesText ? metrics.minimumHorizontalTextScale : 1
        return metrics.titlePointSize * 1.5 * horizontalScale + metrics.horizontalPadding
    }

    /// A title on its own needs only its glyphs to fit; padding is dropped first on short cards.
    public func requiredHeight(for detail: TimelineCardDetail, padded: Bool = true) -> CGFloat {
        switch detail {
        case .bar:
            return 0
        case .title:
            return padded ? metrics.titleLineHeight + metrics.verticalPadding : metrics.titlePointSize
        case .titleAndTime, .full:
            let lines = CGFloat(detail.detailLineCount)
            return metrics.verticalPadding + metrics.titleLineHeight
                + lines * (metrics.lineSpacing + metrics.detailLineHeight)
        }
    }

    private func titleLineLimit(for detail: TimelineCardDetail, height: CGFloat) -> Int {
        guard detail >= .titleAndTime else { return 1 }
        let spare = height - requiredHeight(for: detail)
        let extraLines = Int((spare / metrics.titleLineHeight).rounded(.down))
        return min(max(1 + extraLines, 1), metrics.maximumTitleLines)
    }
}
