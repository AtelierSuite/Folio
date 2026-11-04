import Foundation

enum AlertSchedule {
    case timed(start: Date, end: Date)
    case allDay(start: Date, end: Date)
    case due(Date)
}
