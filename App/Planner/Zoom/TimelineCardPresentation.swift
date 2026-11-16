import CoreGraphics

public struct TimelineCardPresentation: Sendable, Equatable {
    public var detail: TimelineCardDetail
    public var titleLineLimit: Int
    public var showsPadding: Bool

    public init(detail: TimelineCardDetail, titleLineLimit: Int = 1, showsPadding: Bool = true) {
        self.detail = detail
        self.titleLineLimit = titleLineLimit
        self.showsPadding = showsPadding
    }

    public static let bar = TimelineCardPresentation(detail: .bar, showsPadding: false)
}
