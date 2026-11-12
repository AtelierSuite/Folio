import Foundation

public enum FlexTimeDayKind: String, CaseIterable, Sendable, Hashable {
    case weekday
    case weekend
    case publicHoliday

    public var isEnabledByDefault: Bool {
        self != .weekday
    }
}
