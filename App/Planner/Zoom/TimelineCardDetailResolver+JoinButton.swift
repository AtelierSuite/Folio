import CoreGraphics

extension TimelineCardDetailResolver {
    /// The join button needs the time line's height and leaves the title its minimum width beside it.
    public func showsJoinButton(
        for presentation: TimelineCardPresentation, cardSize: CGSize, buttonWidth: CGFloat
    ) -> Bool {
        presentation.detail >= .titleAndTime
            && cardSize.width >= minimumWidth(textScale: presentation.textScale) + buttonWidth
    }
}
