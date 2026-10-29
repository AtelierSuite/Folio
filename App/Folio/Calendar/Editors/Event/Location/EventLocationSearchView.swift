import Planner
import SwiftUI

struct EventLocationSearchView: View {
    @Binding var location: EventLocation?
    @Environment(\.dismiss) private var dismiss
    @State private var search = LocationSearch()
    @State private var isResolving = false

    private var trimmedQuery: String {
        search.query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            List {
                if !trimmedQuery.isEmpty {
                    Button {
                        choose(EventLocation(title: trimmedQuery))
                    } label: {
                        Label(
                            String(localized: "Location.UseText \(trimmedQuery)", table: "EventEditor"),
                            systemImage: "text.cursor"
                        )
                    }
                }
                ForEach(search.suggestions) { suggestion in
                    EventLocationSuggestionRow(suggestion: suggestion) {
                        Task { await resolve(suggestion) }
                    }
                }
                if location != nil {
                    Button(String(localized: "Location.Remove", table: "EventEditor"), role: .destructive) {
                        choose(nil)
                    }
                }
            }
            .disabled(isResolving)
            .overlay {
                if isResolving {
                    ProgressView()
                }
            }
            .searchable(
                text: $search.query,
                placement: .automatic,
                prompt: String(localized: "Location.SearchPrompt", table: "EventEditor")
            )
            .navigationTitle(String(localized: "Field.Location", table: "EventEditor"))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel", table: "EventEditor"), role: .cancel) {
                        dismiss()
                    }
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 420, minHeight: 480)
        #endif
        .onAppear {
            search.query = location?.title ?? ""
        }
    }

    private func resolve(_ suggestion: LocationSearchSuggestion) async {
        isResolving = true
        defer { isResolving = false }
        let resolved = try? await search.location(for: suggestion)
        choose(resolved ?? EventLocation(title: suggestion.title, address: suggestion.subtitle))
    }

    private func choose(_ newLocation: EventLocation?) {
        location = newLocation
        dismiss()
    }
}

private struct EventLocationSuggestionRow: View {
    let suggestion: LocationSearchSuggestion
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "mappin.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.red)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(suggestion.title)
                        .foregroundStyle(.primary)
                    if !suggestion.subtitle.isEmpty {
                        Text(suggestion.subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
