import Foundation

/// Location text that names a link or a video call rather than a place, which MapKit can't geocode.
enum GeocodeQueryFilter {
    // NSDataDetector is immutable once made and safe to share across threads.
    nonisolated(unsafe) private static let linkDetector = try? NSDataDetector(
        types: NSTextCheckingResult.CheckingType.link.rawValue
    )
    private static let fillerWords: Set<String> = ["meeting", "meetings", "call", "video", "online", "conference"]
    private static let extraProviderNames: Set<String> = ["teams", "hangouts", "google hangouts", "skype for business"]

    static func isPlace(_ query: String) -> Bool {
        !containsWebLink(query) && !namesMeetingProvider(query)
    }

    private static func containsWebLink(_ query: String) -> Bool {
        let range = NSRange(query.startIndex..., in: query)
        return linkDetector?.matches(in: query, range: range).contains { match in
            guard let scheme = match.url?.scheme?.lowercased() else { return false }
            return scheme == "http" || scheme == "https"
        } ?? false
    }

    private static func namesMeetingProvider(_ query: String) -> Bool {
        let name = providerName(in: query)
        return !name.isEmpty && providerNames.contains(name)
    }

    private static func providerName(in text: String) -> String {
        text.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty && !fillerWords.contains($0) }
            .joined(separator: " ")
    }

    private static let providerNames = Set(MeetingProvider.allCases.map { providerName(in: $0.displayName) })
        .union(extraProviderNames)
}
