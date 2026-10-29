import Foundation

/// Placeholder until the meeting link detector (#16) lands: any web link counts as a meeting link.
public enum MeetingLink {
    public static func isPresent(in texts: [String?], url: URL? = nil) -> Bool {
        if let url, isWebLink(url) {
            return true
        }
        return texts.contains { text in
            guard let text else { return false }
            return text.range(of: "https://", options: .caseInsensitive) != nil
                || text.range(of: "http://", options: .caseInsensitive) != nil
        }
    }

    /// The link a Join button opens.
    public static func joinURL(in texts: [String?], url: URL? = nil) -> URL? {
        if let url, isWebLink(url) {
            return url
        }
        return texts.lazy.compactMap { $0.flatMap(firstWebLink) }.first
    }

    private static func firstWebLink(in text: String) -> URL? {
        guard isPresent(in: [text]),
              let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return nil
        }
        let range = NSRange(text.startIndex..., in: text)
        return detector.matches(in: text, range: range).lazy
            .filter { match in
                Range(match.range, in: text).map { text[$0].contains("://") } ?? false
            }
            .compactMap(\.url)
            .first(where: isWebLink)
    }

    private static func isWebLink(_ url: URL) -> Bool {
        guard let scheme = url.scheme?.lowercased() else { return false }
        return scheme == "http" || scheme == "https"
    }
}
