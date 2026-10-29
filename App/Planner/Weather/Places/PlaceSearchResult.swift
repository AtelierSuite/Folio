import Foundation

public struct PlaceSearchResult: Sendable, Hashable, Identifiable {
    public let id: Int
    public let title: String
    public let subtitle: String
}
