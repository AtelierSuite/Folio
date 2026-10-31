import Foundation

public enum TimeZoneRegions {
    private final class BundleToken {}

    private static let regionCodes: [String: String] = {
        guard let url = Bundle(for: BundleToken.self).url(forResource: "TimeZoneRegions", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let codes = try? PropertyListDecoder().decode([String: String].self, from: data) else { return [:] }
        return codes
    }()

    public static func regionCode(for identifier: String) -> String? {
        regionCodes[identifier]
    }
}
