import Planner
import SwiftUI

struct EventLocationRow: View {
    @Binding var location: EventLocation?
    var offersSavedLocations = true
    @State private var isSearching = false

    var body: some View {
        Button {
            isSearching = true
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(location?.title ?? String(localized: "Field.Location", table: "EventEditor"))
                        .foregroundStyle(location == nil ? .secondary : .primary)
                    if let address = location?.address {
                        Text(address)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer(minLength: 0)
                if let coordinate = location?.coordinate {
                    EventLocationMiniMap(coordinate: coordinate)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $isSearching) {
            EventLocationSearchView(location: $location, offersSavedLocations: offersSavedLocations)
        }
    }
}
