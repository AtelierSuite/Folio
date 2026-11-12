import Foundation

extension CalendarDataSource {
    /// Events at the times Flex Time shows them, for everything that displays or alerts rather than edits.
    @concurrent
    public func flexTimeEvents(
        in interval: DateInterval,
        schedule: FlexTimeSchedule = FlexTimeStorage().schedule(),
        calendar: Calendar = .current
    ) async -> [CalendarEvent] {
        guard !schedule.isEmpty else { return await events(in: interval) }
        return schedule
            .applying(to: await events(in: schedule.fetchInterval(covering: interval)), calendar: calendar)
            .filter { $0.overlaps(interval) }
    }
}
