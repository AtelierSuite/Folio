import CoreGraphics

/// Text sizes for an event card, already scaled for the user's Dynamic Type size.
public struct TimelineCardTextMetrics: Sendable, Equatable {
    public var titlePointSize: CGFloat
    public var detailPointSize: CGFloat
    public var lineHeightMultiple: CGFloat = 1.2
    public var lineSpacing: CGFloat = 1
    public var verticalPadding: CGFloat = 4
    public var horizontalPadding: CGFloat = 9
    public var minimumPointSize: CGFloat = 6.5
    public var maximumTitleLines = 4

    public init(titlePointSize: CGFloat, detailPointSize: CGFloat) {
        self.titlePointSize = titlePointSize
        self.detailPointSize = detailPointSize
    }

    public var titleLineHeight: CGFloat {
        titlePointSize * lineHeightMultiple
    }

    public var detailLineHeight: CGFloat {
        detailPointSize * lineHeightMultiple
    }

    public var minimumTextScale: CGFloat {
        min(1, minimumPointSize / max(titlePointSize, minimumPointSize))
    }
}
