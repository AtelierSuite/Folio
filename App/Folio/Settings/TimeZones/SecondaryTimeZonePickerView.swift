import Planner
import SwiftUI

struct SecondaryTimeZonePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) private var locale
    @Binding var identifier: String
    @State private var options: [TimeZoneOption] = []
    @State private var query = ""

    var body: some View {
        let matches = TimeZoneCatalog.filter(options, by: query)
        List(matches) { option in
            Button {
                identifier = option.identifier
                dismiss()
            } label: {
                TimeZoneOptionRow(option: option, isSelected: option.identifier == identifier)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("TimeZoneOption.\(option.identifier)")
        }
        .overlay {
            if matches.isEmpty && !options.isEmpty {
                ContentUnavailableView.search(text: query)
            }
        }
        .searchable(text: $query, placement: searchPlacement, prompt: String(localized: "Picker.SearchPrompt", table: "TimeZones"))
        .navigationTitle(String(localized: "Picker.Title", table: "TimeZones"))
        .task(id: locale) {
            options = TimeZoneCatalog.options(locale: locale)
        }
    }

    private var searchPlacement: SearchFieldPlacement {
        #if os(iOS)
        .navigationBarDrawer(displayMode: .always)
        #else
        .automatic
        #endif
    }
}
