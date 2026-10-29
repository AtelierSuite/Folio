import Foundation

public struct EventParticipant: Sendable, Hashable, Identifiable {
    public let name: String?
    public let url: URL?
    public let role: ParticipantRole
    public let type: ParticipantType
    public let status: ParticipantStatus
    public let isCurrentUser: Bool

    public init(
        name: String?,
        url: URL?,
        role: ParticipantRole = .required,
        type: ParticipantType = .person,
        status: ParticipantStatus = .pending,
        isCurrentUser: Bool = false
    ) {
        self.name = name.flatMap { $0.isEmpty ? nil : $0 }
        self.url = url
        self.role = role
        self.type = type
        self.status = status
        self.isCurrentUser = isCurrentUser
    }

    public var id: String {
        url?.absoluteString ?? name ?? ""
    }

    public var emailAddress: String? {
        guard let url, url.scheme?.lowercased() == "mailto" else { return nil }
        let address = String(url.absoluteString.dropFirst("mailto:".count))
        return address.removingPercentEncoding ?? address
    }

    public var displayName: String {
        name ?? emailAddress ?? url?.absoluteString ?? ""
    }
}
