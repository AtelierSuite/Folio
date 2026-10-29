import Foundation

public struct SearchQuery: Sendable, Hashable {
    public var text: String
    public var kinds: Set<SearchItemKind>
    /// `nil` matches every calendar and list. Notes have no calendar, so they never match a calendar filter.
    public var containerIdentifiers: Set<String>?
    public var excludedContainerIdentifiers: Set<String>
    public var dateInterval: DateInterval?
    public var requiresMeetingLink: Bool

    public init(
        text: String = "",
        kinds: Set<SearchItemKind> = Set(SearchItemKind.allCases),
        containerIdentifiers: Set<String>? = nil,
        excludedContainerIdentifiers: Set<String> = [],
        dateInterval: DateInterval? = nil,
        requiresMeetingLink: Bool = false
    ) {
        self.text = text
        self.kinds = kinds
        self.containerIdentifiers = containerIdentifiers
        self.excludedContainerIdentifiers = excludedContainerIdentifiers
        self.dateInterval = dateInterval
        self.requiresMeetingLink = requiresMeetingLink
    }

    public var hasNarrowingFilter: Bool {
        containerIdentifiers != nil || dateInterval != nil || requiresMeetingLink
    }

    func matches(_ document: SearchDocument) -> Bool {
        guard kinds.contains(document.kind) else { return false }
        if let container = document.containerIdentifier, excludedContainerIdentifiers.contains(container) {
            return false
        }
        if let containerIdentifiers {
            guard let container = document.containerIdentifier, containerIdentifiers.contains(container) else {
                return false
            }
        }
        if let dateInterval, !document.isDated(in: dateInterval) {
            return false
        }
        return !requiresMeetingLink || document.hasMeetingLink
    }
}
