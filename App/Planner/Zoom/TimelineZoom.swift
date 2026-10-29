import CoreGraphics
import Foundation

/// Hour heights run from "the whole day fits in the viewport" up to `maximumHourHeight`.
public struct TimelineZoom: Sendable, Equatable {
    public var defaultHourHeight: CGFloat = 48
    public var maximumHourHeight: CGFloat = 240
    public var stepFactor: CGFloat = 1.25
    public var detailStepFactor: CGFloat = 1.18
    public var fitTolerance: CGFloat = 0.5

    public init() {}

    public func fittingHourHeight(viewportHeight: CGFloat, verticalInset: CGFloat) -> CGFloat {
        max(1, (viewportHeight - verticalInset * 2) / 24)
    }

    public func clamped(_ hourHeight: CGFloat, fitting fittingHourHeight: CGFloat) -> CGFloat {
        min(max(hourHeight, fittingHourHeight), max(maximumHourHeight, fittingHourHeight))
    }

    public func hourHeight(for level: TimelineZoomLevel, fitting fittingHourHeight: CGFloat) -> CGFloat {
        switch level {
        case .fitsWholeDay: fittingHourHeight
        case .hourHeight(let hourHeight): clamped(hourHeight, fitting: fittingHourHeight)
        }
    }

    public func level(for hourHeight: CGFloat, fitting fittingHourHeight: CGFloat) -> TimelineZoomLevel {
        guard hourHeight > fittingHourHeight + fitTolerance else { return .fitsWholeDay }
        return .hourHeight(min(hourHeight, maximumHourHeight))
    }

    public func zoomedIn(from hourHeight: CGFloat, fitting fittingHourHeight: CGFloat) -> CGFloat {
        clamped(hourHeight * stepFactor, fitting: fittingHourHeight)
    }

    public func zoomedOut(from hourHeight: CGFloat, fitting fittingHourHeight: CGFloat) -> CGFloat {
        clamped(hourHeight / stepFactor, fitting: fittingHourHeight)
    }

    public func canZoomIn(from hourHeight: CGFloat) -> Bool {
        hourHeight < maximumHourHeight - fitTolerance
    }

    public func canZoomOut(from hourHeight: CGFloat, fitting fittingHourHeight: CGFloat) -> Bool {
        hourHeight > fittingHourHeight + fitTolerance
    }

    /// While pinching, the timeline is only laid out again when the hour height enters a new step.
    public func detailStep(for hourHeight: CGFloat) -> Int {
        Int((log(max(hourHeight, 1)) / log(detailStepFactor)).rounded(.down))
    }
}
