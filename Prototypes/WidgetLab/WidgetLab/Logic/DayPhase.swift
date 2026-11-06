import Foundation

enum DayPhase: Equatable {
    case morning, daytime, evening

    static func phase(at date: Date, calendar: Calendar) -> DayPhase {
        switch calendar.component(.hour, from: date) {
        case 4..<11: .morning
        case 11..<18: .daytime
        default: .evening
        }
    }
}
