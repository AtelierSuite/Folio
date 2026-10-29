import CoreGraphics

public enum TimelineZoomLevel: Sendable, Equatable {
    case fitsWholeDay
    case hourHeight(CGFloat)

    /// Stored as a plain number so it fits in `UserDefaults`: `0` means the whole day fits.
    public init(storedValue: Double) {
        self = storedValue > 0 ? .hourHeight(CGFloat(storedValue)) : .fitsWholeDay
    }

    public var storedValue: Double {
        switch self {
        case .fitsWholeDay: 0
        case .hourHeight(let hourHeight): Double(hourHeight)
        }
    }
}
