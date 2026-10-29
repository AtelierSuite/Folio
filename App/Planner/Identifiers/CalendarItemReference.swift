import Foundation

public struct CalendarItemReference: Sendable, Hashable, Codable {
    public let externalIdentifier: String?
    public let localIdentifier: String
    public let calendarIdentifier: String
    public let occurrenceDate: Date?
    public let title: String
    public let startDate: Date?

    public init(
        externalIdentifier: String?,
        localIdentifier: String,
        calendarIdentifier: String,
        occurrenceDate: Date? = nil,
        title: String,
        startDate: Date? = nil
    ) {
        self.externalIdentifier = externalIdentifier.flatMap { $0.isEmpty ? nil : $0 }
        self.localIdentifier = localIdentifier
        self.calendarIdentifier = calendarIdentifier
        self.occurrenceDate = occurrenceDate
        self.title = title
        self.startDate = startDate
    }

    public var storageKey: String {
        let identity = externalIdentifier ?? "local:\(localIdentifier)"
        guard let occurrenceDate else { return identity }
        return "\(identity)@\(Int(occurrenceDate.timeIntervalSince1970.rounded()))"
    }
}
