import Foundation

public struct ReminderEarlyAlert: Codable, Sendable, Hashable {
    public enum Unit: String, Codable, Sendable, CaseIterable {
        case minutes
        case hours
        case days
        case weeks
        case months

        var component: Calendar.Component {
            switch self {
            case .minutes: .minute
            case .hours: .hour
            case .days: .day
            case .weeks: .weekOfMonth
            case .months: .month
            }
        }
    }

    public static let countRange = 1...999
    public static let standard = ReminderEarlyAlert(count: 1, unit: .days)

    public var count: Int {
        didSet { count = min(max(count, Self.countRange.lowerBound), Self.countRange.upperBound) }
    }
    public var unit: Unit

    public init(count: Int, unit: Unit) {
        self.count = min(max(count, Self.countRange.lowerBound), Self.countRange.upperBound)
        self.unit = unit
    }

    public var dateComponents: DateComponents {
        var components = DateComponents()
        components.setValue(count, for: unit.component)
        return components
    }

    public func fireDate(before anchor: Date, in calendar: Calendar) -> Date? {
        calendar.date(byAdding: unit.component, value: -count, to: anchor)
    }
}
