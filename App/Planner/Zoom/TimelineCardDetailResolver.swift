import CoreGraphics

/// Picks how much an event card shows for its size: title, time, location and link icon, then
/// title and time, then the title, then just a colored bar. With `compressesText` the text
/// shrinks (down to `minimumPointSize`) to fit instead of dropping detail or being cut off.
public struct TimelineCardDetailResolver: Sendable, Equatable {
    public var metrics: TimelineCardTextMetrics
    public var compressesText: Bool

    public init(metrics: TimelineCardTextMetrics, compressesText: Bool) {
        self.metrics = metrics
        self.compressesText = compressesText
    }

    public func presentation(for size: CGSize) -> TimelineCardPresentation {
        let lowestScale = compressesText ? metrics.minimumTextScale : 1
        guard size.width >= minimumWidth(textScale: lowestScale) else { return .bar }
        for detail in TimelineCardDetail.allCases.reversed() where detail != .bar {
            let scale = textScale(for: detail, height: size.height)
            guard scale >= lowestScale else { continue }
            let paddedTitleHeight = requiredHeight(for: .title, textScale: scale, padded: true)
            return TimelineCardPresentation(
                detail: detail,
                textScale: scale,
                titleLineLimit: titleLineLimit(for: detail, height: size.height, textScale: scale),
                showsPadding: detail != .title || size.height >= paddedTitleHeight
            )
        }
        return .bar
    }

    public func minimumWidth(textScale: CGFloat) -> CGFloat {
        metrics.titlePointSize * textScale * 1.5 + metrics.horizontalPadding
    }

    /// A title on its own needs only its glyphs to fit; padding is dropped first on short cards.
    public func requiredHeight(for detail: TimelineCardDetail, textScale: CGFloat, padded: Bool = true) -> CGFloat {
        switch detail {
        case .bar:
            return 0
        case .title:
            let glyphs = metrics.titlePointSize * textScale
            return padded ? metrics.titleLineHeight * textScale + metrics.verticalPadding : glyphs
        case .titleAndTime, .full:
            let lines = CGFloat(detail.detailLineCount)
            return metrics.verticalPadding + metrics.titleLineHeight * textScale
                + lines * (metrics.lineSpacing + metrics.detailLineHeight * textScale)
        }
    }

    private func textScale(for detail: TimelineCardDetail, height: CGFloat) -> CGFloat {
        let fullSize = requiredHeight(for: detail, textScale: 1, padded: false)
        guard height < fullSize else { return 1 }
        guard compressesText else { return 0 }
        let fixed = requiredHeight(for: detail, textScale: 0, padded: false)
        let scalable = fullSize - fixed
        guard scalable > 0 else { return 0 }
        return max(0, (height - fixed) / scalable)
    }

    private func titleLineLimit(for detail: TimelineCardDetail, height: CGFloat, textScale: CGFloat) -> Int {
        guard detail >= .titleAndTime else { return 1 }
        let spare = height - requiredHeight(for: detail, textScale: textScale)
        let extraLines = Int((spare / (metrics.titleLineHeight * textScale)).rounded(.down))
        return min(max(1 + extraLines, 1), metrics.maximumTitleLines)
    }
}
