import Foundation

public enum MeetingLinkDetector {
    // NSDataDetector is immutable once made and safe to share across threads.
    nonisolated(unsafe) private static let linkDetector = try? NSDataDetector(
        types: NSTextCheckingResult.CheckingType.link.rawValue
    )

    /// The URL field wins over the location, and the location over the notes.
    public static func link(url: URL?, texts: [String?]) -> MeetingLink? {
        if let url, let link = link(for: url) {
            return link
        }
        for case let text? in texts {
            if let link = firstLink(in: text) {
                return link
            }
        }
        return nil
    }

    public static func link(for url: URL) -> MeetingLink? {
        let unwrapped = MeetingLinkUnwrapper.unwrap(url)
        guard let provider = MeetingLinkRule.provider(for: unwrapped) else { return nil }
        return MeetingLink(provider: provider, url: unwrapped)
    }

    public static func firstLink(in text: String) -> MeetingLink? {
        guard !text.isEmpty else { return nil }
        return candidateURLs(in: text).lazy.compactMap(link(for:)).first
    }

    private static func candidateURLs(in text: String) -> [URL] {
        let range = NSRange(text.startIndex..., in: text)
        return linkDetector?.matches(in: text, range: range).compactMap(\.url) ?? []
    }
}
