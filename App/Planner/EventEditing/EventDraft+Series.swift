import Foundation

extension EventDraft {
    /// Moves an edit made on one occurrence onto the first occurrence of its series, keeping
    /// the change in start time and the new duration, so it can be saved with `futureEvents`.
    public func appliedToSeries(
        editedOccurrenceStart: Date,
        firstOccurrenceStart: Date,
        calendar: Calendar = .current
    ) -> EventDraft {
        let components: Set<Calendar.Component> = [.day, .hour, .minute, .second]
        let shift = calendar.dateComponents(components, from: editedOccurrenceStart, to: startDate)
        let length = calendar.dateComponents(components, from: startDate, to: endDate)
        var seriesDraft = self
        seriesDraft.startDate = calendar.date(byAdding: shift, to: firstOccurrenceStart) ?? firstOccurrenceStart
        seriesDraft.endDate = calendar.date(byAdding: length, to: seriesDraft.startDate) ?? seriesDraft.startDate
        return seriesDraft
    }
}
