import CoreGraphics

public struct TimelineCardPresentation: Sendable, Equatable {
    public var detail: TimelineCardDetail
    public var textScale: CGFloat
    public var titleLineLimit: Int
    public var showsPadding: Bool

    public init(
        detail: TimelineCardDetail, textScale: CGFloat = 1, titleLineLimit: Int = 1, showsPadding: Bool = true
    ) {
        self.detail = detail
        self.textScale = textScale
        self.titleLineLimit = titleLineLimit
        self.showsPadding = showsPadding
    }

    public static let bar = TimelineCardPresentation(detail: .bar, showsPadding: false)
}
