import MapKit
import Planner
import SwiftUI

struct EventDetailLocationSection: View {
    let location: EventLocation

    var body: some View {
        Section {
            Label {
                VStack(alignment: .leading, spacing: 2) {
                    Text(location.title)
                    if let address = location.address {
                        Text(address)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .textSelection(.enabled)
            } icon: {
                Image(systemName: "mappin.and.ellipse")
            }
            if let coordinate = location.coordinate {
                let center = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
                Map(initialPosition: .region(MKCoordinateRegion(
                    center: center,
                    latitudinalMeters: 800,
                    longitudinalMeters: 800
                ))) {
                    Marker(location.title, coordinate: center)
                }
                .frame(height: 180)
                #if os(macOS)
                .clipShape(.rect(cornerRadius: 8))
                #endif
                .allowsHitTesting(false)
                .overlay {
                    Button {
                        openInMaps(at: center)
                    } label: {
                        Color.clear
                            .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(String(localized: "Event.Location.OpenInMaps", table: "Calendar"))
                }
                #if os(iOS)
                .listRowInsets(EdgeInsets())
                #endif
            }
        }
    }

    private func openInMaps(at center: CLLocationCoordinate2D) {
        let mapItem = MKMapItem(
            location: CLLocation(latitude: center.latitude, longitude: center.longitude),
            address: nil
        )
        mapItem.name = location.title
        mapItem.openInMaps()
    }
}
