import Planner
import SwiftUI

extension CalendarView {
    func show(_ destination: AppDestination) -> Bool {
        switch destination {
        case .calendarDay(let date, let item):
            if mode == .list {
                mode = .day
            }
            navigation.show(date)
            if let item {
                Task {
                    routedEvent = await store.event(matching: item, on: date)
                }
            }
            return true
        case .newEvent:
            composer = .newEvent
            return true
        case .newReminder:
            composer = .newReminder
            return true
        case .note, .newNote:
            return false
        }
    }
}
