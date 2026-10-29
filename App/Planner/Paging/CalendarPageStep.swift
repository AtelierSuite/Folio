import Foundation

public struct CalendarPageStep: Sendable, Hashable {
    public let component: Calendar.Component
    public let value: Int

    public init(component: Calendar.Component, value: Int = 1) {
        self.component = component
        self.value = value
    }

    public static let day = CalendarPageStep(component: .day)
    public static let week = CalendarPageStep(component: .weekOfYear)
    public static let month = CalendarPageStep(component: .month)

    public func date(from date: Date, toward direction: CalendarPageDirection, in calendar: Calendar) -> Date {
        let noon = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: date) ?? date
        let moved = calendar.date(byAdding: component, value: value * direction.sign, to: noon) ?? noon
        return calendar.startOfDay(for: moved)
    }
}
