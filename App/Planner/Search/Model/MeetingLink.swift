import Foundation

/// Placeholder until the meeting link detector (#16) lands: any web link counts as a meeting link.
public enum MeetingLink {
    public static func isPresent(in texts: [String?], url: URL? = nil) -> Bool {
        if let scheme = url?.scheme?.lowercased(), scheme == "http" || scheme == "https" {
            return true
        }
        return texts.contains { text in
            guard let text else { return false }
            return text.range(of: "https://", options: .caseInsensitive) != nil
                || text.range(of: "http://", options: .caseInsensitive) != nil
        }
    }
}
