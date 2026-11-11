import Foundation

extension CalendarEvent {
    public var isDelayedByFlexTime: Bool {
        flexTimeDelay != 0
    }

    /// When the event really starts in the calendar, before Flex Time moves it.
    public var scheduledStartDate: Date {
        startDate.addingTimeInterval(-flexTimeDelay)
    }

    public var scheduledEndDate: Date {
        endDate.addingTimeInterval(-flexTimeDelay)
    }

    public func delayed(by delay: TimeInterval) -> CalendarEvent {
        var event = self
        event.startDate = startDate.addingTimeInterval(delay)
        event.endDate = endDate.addingTimeInterval(delay)
        event.alarms = alarms.map { alarm in
            guard case .absolute(let date) = alarm else { return alarm }
            return .absolute(date: date.addingTimeInterval(delay))
        }
        event.flexTimeDelay = flexTimeDelay + delay
        return event
    }

    public var withoutFlexTime: CalendarEvent {
        isDelayedByFlexTime ? delayed(by: -flexTimeDelay) : self
    }
}
