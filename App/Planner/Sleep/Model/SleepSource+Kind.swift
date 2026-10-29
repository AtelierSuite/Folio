import Foundation

extension SleepSource.Kind {
    /// Only Apple's own sources count as Watch or iPhone, so a third-party app can't jump the queue.
    public init(bundleIdentifier: String, productType: String?) {
        let productType = productType?.lowercased() ?? ""
        guard bundleIdentifier.hasPrefix("com.apple.health") else {
            self = .other
            return
        }
        if productType.hasPrefix("watch") {
            self = .watch
        } else if productType.hasPrefix("iphone") {
            self = .phone
        } else {
            self = .other
        }
    }
}
