import Foundation

/// The one place notifications find an event's meeting link; point it at the meeting link detector (#16) when it lands.
public enum NotificationMeetingLink {
    public static func url(for event: CalendarEvent) -> URL? {
        if let url = event.url, isWebLink(url) {
            return url
        }
        return [event.location, event.notes].lazy.compactMap { $0.flatMap(firstWebLink(in:)) }.first
    }

    static func isWebLink(_ text: String) -> Bool {
        URL(string: text).map(isWebLink) ?? false
    }

    private static func isWebLink(_ url: URL) -> Bool {
        let scheme = url.scheme?.lowercased()
        return (scheme == "http" || scheme == "https") && url.host() != nil
    }

    private static func firstWebLink(in text: String) -> URL? {
        guard MeetingLink.isPresent(in: [text]),
              let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return nil
        }
        let range = NSRange(text.startIndex..., in: text)
        return detector.matches(in: text, range: range).lazy.compactMap(\.url).first(where: isWebLink)
    }
}
