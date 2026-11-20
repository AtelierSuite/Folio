import Foundation

/// `folio://reonboard` shows the onboarding sheet again.
public enum OnboardingDeepLink {
    public static let host = "reonboard"

    public static var url: URL {
        var components = URLComponents()
        components.scheme = NoteDeepLink.scheme
        components.host = host
        return components.url!
    }

    public static func isReonboard(_ url: URL) -> Bool {
        url.scheme?.lowercased() == NoteDeepLink.scheme && url.host(percentEncoded: false)?.lowercased() == host
    }
}
