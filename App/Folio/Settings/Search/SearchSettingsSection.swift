import Planner
import SwiftUI

struct SearchSettingsSection: View {
    @Environment(SearchIndexer.self) private var indexer

    private static let monthsBackOptions = [6, 12, 24, 36, 60]
    private static let monthsAheadOptions = [3, 6, 12, 24]

    var body: some View {
        Section {
            Picker(String(localized: "Settings.MonthsBack", table: "Search"), selection: binding(\.monthsBack)) {
                options(Self.monthsBackOptions)
            }
            .accessibilityIdentifier("Search.Settings.MonthsBack")
            Picker(String(localized: "Settings.MonthsAhead", table: "Search"), selection: binding(\.monthsAhead)) {
                options(Self.monthsAheadOptions)
            }
            .accessibilityIdentifier("Search.Settings.MonthsAhead")
        } header: {
            Text(String(localized: "Settings.Header", table: "Search"))
        } footer: {
            Text(String(localized: "Settings.Footer", table: "Search"))
        }
    }

    private func binding(_ keyPath: WritableKeyPath<SearchRange, Int>) -> Binding<Int> {
        Binding {
            indexer.range[keyPath: keyPath]
        } set: { months in
            var range = indexer.range
            range[keyPath: keyPath] = months
            Task {
                await indexer.setRange(range)
            }
        }
    }

    private func options(_ months: [Int]) -> some View {
        ForEach(months, id: \.self) { count in
            Text(Self.duration(months: count)).tag(count)
        }
    }

    private static func duration(months: Int) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.year, .month]
        let components = months.isMultiple(of: 12) ? DateComponents(year: months / 12) : DateComponents(month: months)
        return formatter.string(from: components) ?? "\(months)"
    }
}
