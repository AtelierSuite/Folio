import Foundation

public struct SyncedDefaultsDomain: @unchecked Sendable {
    public let defaults: UserDefaults
    public let keys: [String]

    public init(defaults: UserDefaults, keys: [String]) {
        self.defaults = defaults
        self.keys = keys
    }
}
