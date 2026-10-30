import Planner
import SwiftUI

extension View {
    /// A tap opens the day; a double tap on the cell's empty space asks to add an event or reminder on it.
    func calendarMonthDayTaps(_ day: MonthDay, onSelect: @escaping () -> Void) -> some View {
        modifier(CalendarMonthDayTapsModifier(day: day, onSelect: onSelect))
    }
}

/// The empty space behind the chips takes the taps, so a tap on a chip still reaches the chip.
private struct CalendarMonthDayTapsModifier: ViewModifier {
    @Environment(\.calendarCreation) private var creation
    let day: MonthDay
    let onSelect: () -> Void

    func body(content: Content) -> some View {
        content
            .background {
                Color.clear
                    .contentShape(.rect)
                    .gesture(
                        SpatialTapGesture(count: 2, coordinateSpace: CalendarCreationAction.coordinateSpace)
                            .exclusively(before: TapGesture())
                            .onEnded(handle),
                        isEnabled: creation != nil
                    )
            }
            .onTapGesture(perform: onSelect)
    }

    private func handle(_ value: ExclusiveGesture<SpatialTapGesture, TapGesture>.Value) {
        switch value {
        case .first(let doubleTap):
            creation?(CalendarCreationSlot(date: day.date, hasTime: false), at: doubleTap.location)
        case .second:
            onSelect()
        }
    }
}
