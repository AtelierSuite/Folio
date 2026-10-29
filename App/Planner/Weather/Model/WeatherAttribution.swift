import Foundation

/// Apple Weather must be credited with its mark and a link to the legal page wherever weather appears.
public struct WeatherAttribution: Sendable, Hashable, Codable {
    public static let defaultLegalPageURL = URL(string: "https://weatherkit.apple.com/legal-attribution.html")!

    public let serviceName: String
    public let legalPageURL: URL
    public let markLightURL: URL?
    public let markDarkURL: URL?

    public init(serviceName: String, legalPageURL: URL, markLightURL: URL?, markDarkURL: URL?) {
        self.serviceName = serviceName
        self.legalPageURL = legalPageURL
        self.markLightURL = markLightURL
        self.markDarkURL = markDarkURL
    }

    public static let placeholder = WeatherAttribution(
        serviceName: "Apple Weather", legalPageURL: defaultLegalPageURL, markLightURL: nil, markDarkURL: nil
    )
}
