import Foundation

extension CalendarItemReference {
    static let localIdentityPrefix = "local:"

    /// Rebuilds what a `storageKey` remembers (identifiers and occurrence), so a stored key can still
    /// match its event through `bestMatch(in:)` after its identifiers change.
    init?(storageKey: String) {
        var identity = storageKey
        var occurrenceDate: Date?
        if let separator = storageKey.lastIndex(of: "@"),
           let seconds = Int(storageKey[storageKey.index(after: separator)...]) {
            identity = String(storageKey[..<separator])
            occurrenceDate = Date(timeIntervalSince1970: TimeInterval(seconds))
        }
        guard !identity.isEmpty else {
            return nil
        }
        let isLocal = identity.hasPrefix(Self.localIdentityPrefix)
        self.init(
            externalIdentifier: isLocal ? nil : identity,
            localIdentifier: isLocal ? String(identity.dropFirst(Self.localIdentityPrefix.count)) : "",
            calendarIdentifier: "",
            occurrenceDate: occurrenceDate,
            title: ""
        )
    }
}
