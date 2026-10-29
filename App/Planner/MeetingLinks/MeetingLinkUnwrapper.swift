import Foundation

/// Mail security gateways and redirectors wrap links in invitations; the meeting link is the wrapped one.
enum MeetingLinkUnwrapper {
    private static let maximumDepth = 3

    static func unwrap(_ url: URL) -> URL {
        var current = url
        for _ in 0..<maximumDepth {
            guard let inner = wrappedURL(in: current) else { break }
            current = inner
        }
        return current
    }

    private static func wrappedURL(in url: URL) -> URL? {
        guard let host = url.host(percentEncoded: false)?.lowercased() else { return nil }
        if host.hasSuffix("safelinks.protection.outlook.com") || host.hasSuffix("safelinks.protection.office365.us") {
            return queryURL(named: "url", in: url)
        }
        if host == "www.google.com" || host == "google.com", url.path() == "/url" {
            return queryURL(named: "q", in: url) ?? queryURL(named: "url", in: url)
        }
        if host == "urldefense.com" {
            return proofpointURL(in: url)
        }
        return nil
    }

    private static func queryURL(named name: String, in url: URL) -> URL? {
        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        guard let value = items.first(where: { $0.name.lowercased() == name })?.value else { return nil }
        return webURL(from: value)
    }

    /// `https://urldefense.com/v3/__<link>__;<checksum>`
    private static func proofpointURL(in url: URL) -> URL? {
        let text = url.absoluteString
        guard let start = text.range(of: "/v3/__"),
              let end = text.range(of: "__;", range: start.upperBound..<text.endIndex) else { return nil }
        return webURL(from: String(text[start.upperBound..<end.lowerBound]))
    }

    private static func webURL(from text: String) -> URL? {
        guard let url = URL(string: text), let scheme = url.scheme?.lowercased(),
              scheme == "https" || scheme == "http" || MeetingLinkRule.customSchemes[scheme] != nil else { return nil }
        return url
    }
}
