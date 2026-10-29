import Planner
import SwiftUI

struct EventLocationRow: View {
    @Binding var location: EventLocation?
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
                if location?.coordinate != nil {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(.red)
                        .accessibilityHidden(true)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $isSearching) {
            EventLocationSearchView(location: $location)
        }
    }
}
