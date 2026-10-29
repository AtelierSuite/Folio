import Foundation

enum MultiDayCount: Int, CaseIterable, Identifiable {
    case two = 2
    case three = 3

    var id: Self { self }

    var title: String {
        switch self {
        case .two: String(localized: "DayCount.Two", table: "Day")
        case .three: String(localized: "DayCount.Three", table: "Day")
        }
    }

    var systemImage: String {
        switch self {
        case .two: "2.square"
        case .three: "3.square"
        }
    }
}
