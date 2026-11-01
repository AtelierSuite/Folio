import Foundation

public struct HolidayCacheEntry: Codable, Sendable {
    public let fetchedAt: Date
    public let years: ClosedRange<Int>
    public let holidays: [Holiday]
}
