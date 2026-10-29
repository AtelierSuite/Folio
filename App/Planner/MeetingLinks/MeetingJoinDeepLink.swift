import Foundation

/// `folio://join?url=<meeting link>`
public enum MeetingJoinDeepLink {
    public static let host = "join"

    public static func url(for link: MeetingLink) -> URL? {
        var components = URLComponents()
        components.scheme = NoteDeepLink.scheme
        components.host = host
        components.queryItems = [URLQueryItem(name: "url", value: link.url.absoluteString)]
        return components.url
    }

    /// Only links the detector recognizes are opened, so a crafted Folio link can't open anything else.
    public static func meetingLink(from url: URL) -> MeetingLink? {
        guard url.scheme?.lowercased() == NoteDeepLink.scheme, url.host(percentEncoded: false)?.lowercased() == host,
              let value = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                .queryItems?.first(where: { $0.name == "url" })?.value,
              let meetingURL = URL(string: value) else { return nil }
        return MeetingLinkDetector.link(for: meetingURL)
    }
}
