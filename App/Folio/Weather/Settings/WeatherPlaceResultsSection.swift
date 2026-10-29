import Planner
import SwiftUI

struct WeatherPlaceResultsSection: View {
    let results: [PlaceSearchResult]
    let select: (PlaceSearchResult) -> Void

    var body: some View {
        Section {
            ForEach(results) { result in
                Button {
                    select(result)
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(result.title)
                            .foregroundStyle(.primary)
                        if !result.subtitle.isEmpty {
                            Text(result.subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }
}
