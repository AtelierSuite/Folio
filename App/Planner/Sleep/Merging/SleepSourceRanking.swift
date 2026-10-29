import Foundation

/// Orders sources by trust: the user's preferred source, then Apple Watch, then iPhone, then other apps.
public struct SleepSourceRanking: Sendable {
    public let preferredSourceIdentifier: String?

    public init(preferredSourceIdentifier: String? = nil) {
        self.preferredSourceIdentifier = preferredSourceIdentifier
    }

    public func ranked(_ sources: some Sequence<SleepSource>) -> [SleepSource] {
        Set(sources).sorted(by: isRankedHigher)
    }

    public func isRankedHigher(_ lhs: SleepSource, than rhs: SleepSource) -> Bool {
        let lhsPreferred = lhs.id == preferredSourceIdentifier
        let rhsPreferred = rhs.id == preferredSourceIdentifier
        if lhsPreferred != rhsPreferred { return lhsPreferred }
        if lhs.kind != rhs.kind { return lhs.kind < rhs.kind }
        if lhs.name != rhs.name { return lhs.name < rhs.name }
        return lhs.id < rhs.id
    }
}
