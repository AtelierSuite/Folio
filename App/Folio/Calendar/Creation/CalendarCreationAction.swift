import SwiftUI

/// Asks whether to add an event or a reminder at a spot the user double tapped.
struct CalendarCreationAction {
    static let coordinateSpace = NamedCoordinateSpace.named("CalendarCreation")

    let present: (CalendarCreationSlot, CGPoint) -> Void

    /// `point` is in `coordinateSpace`.
    func callAsFunction(_ slot: CalendarCreationSlot, at point: CGPoint) {
        present(slot, point)
    }
}

struct CalendarCreationSlot: Equatable {
    let date: Date
    /// `false` for a whole day, such as a day in the month view.
    let hasTime: Bool
}

extension EnvironmentValues {
    @Entry var calendarCreation: CalendarCreationAction?
}
