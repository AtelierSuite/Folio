import Foundation

public struct MeetingLink: Sendable, Hashable, Codable {
    public let provider: MeetingProvider
    public let url: URL

    public init(provider: MeetingProvider, url: URL) {
        self.provider = provider
        self.url = url
    }

    public var displayName: String {
        provider.displayName
    }

    /// Opens the meeting through Folio, for surfaces that can only open the app's own links (widgets).
    public var joinDeepLink: URL? {
        MeetingJoinDeepLink.url(for: self)
    }

    public static func isPresent(in texts: [String?], url: URL? = nil) -> Bool {
        MeetingLinkDetector.link(url: url, texts: texts) != nil
    }
}
