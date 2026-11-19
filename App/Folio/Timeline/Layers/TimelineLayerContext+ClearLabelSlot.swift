import Planner

extension TimelineLayerContext {
    /// The first spot in `segment`, from the top, where a label of `heightHours` fits at the
    /// leading edge without running under a card, sized to the clear width in front of the cards.
    func clearLabelSlot(
        in segment: TimelineDaySegment, heightHours: Double, minimumWidthFraction: Double
    ) -> TimelineSlot? {
        let dayCards = cardSlots.filter { $0.dayIndex == segment.dayIndex }
        let candidateStartHours = ([segment.startHour] + dayCards.map(\.endHour))
            .filter { $0 >= segment.startHour }
            .sorted()
        for startHour in candidateStartHours {
            let endHour = startHour + heightHours
            guard endHour <= segment.endHour else { return nil }
            let clearWidth = dayCards
                .filter { $0.startHour < endHour && $0.endHour > startHour }
                .map(\.leadingFraction)
                .min() ?? 1
            if clearWidth >= minimumWidthFraction {
                return TimelineSlot(
                    dayIndex: segment.dayIndex, startHour: startHour, endHour: endHour, widthFraction: clearWidth
                )
            }
        }
        return nil
    }
}
