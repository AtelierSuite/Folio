import Foundation

public struct Holiday: Codable, Hashable, Sendable {
    public let day: HolidayDay
    public let name: String

    public init(day: HolidayDay, name: String) {
        self.day = day
        self.name = name
    }
}
