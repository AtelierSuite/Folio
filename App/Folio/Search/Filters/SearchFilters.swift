import Foundation
import Planner

struct SearchFilters: Hashable {
    var text = ""
    var kind: SearchItemKind?
    var containerIdentifier: String?
    var dateFilter: SearchDateFilter?
    var requiresMeetingLink = false

    var isFiltering: Bool {
        kind != nil || containerIdentifier != nil || dateFilter != nil || requiresMeetingLink
    }

    mutating func clear() {
        kind = nil
        containerIdentifier = nil
        dateFilter = nil
        requiresMeetingLink = false
    }

    func query(hiding hiddenIdentifiers: Set<String>, now: Date = .now) -> SearchQuery {
        SearchQuery(
            text: text,
            kinds: kind.map { [$0] } ?? Set(SearchItemKind.allCases),
            containerIdentifiers: containerIdentifier.map { [$0] },
            excludedContainerIdentifiers: hiddenIdentifiers,
            dateInterval: dateFilter?.interval(around: now),
            requiresMeetingLink: requiresMeetingLink
        )
    }
}
