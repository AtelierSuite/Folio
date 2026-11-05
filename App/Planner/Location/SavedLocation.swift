import Foundation

public struct SavedLocation: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public var name: String
    public var location: EventLocation

    public init(id: UUID = UUID(), name: String, location: EventLocation) {
        self.id = id
        self.name = name
        self.location = location
    }

    public var summary: String {
        [location.title, location.address].compactMap(\.self).joined(separator: ", ")
    }

    public func matches(_ query: String) -> Bool {
        name.localizedCaseInsensitiveContains(query) || summary.localizedCaseInsensitiveContains(query)
    }
}
