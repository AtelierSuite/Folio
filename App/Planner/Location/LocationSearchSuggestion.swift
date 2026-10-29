import Foundation

public struct LocationSearchSuggestion: Identifiable, Hashable, Sendable {
    public let title: String
    public let subtitle: String

    public var id: String {
        "\(title)\n\(subtitle)"
    }
}
