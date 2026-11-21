import MapKit
import Planner
import SwiftUI

struct EventDetailLocationSection: View {
    let location: EventLocation

    @Environment(\.openURL) private var openURL

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
                        open(DirectionsSettings().placeURL(for:))
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
            if destination != nil {
                Button {
                    open { DirectionsSettings().url(for: DirectionsRequest(destination: $0)) }
                } label: {
                    Label(
                        String(localized: "Event.Location.Directions", table: "Calendar"),
                        systemImage: "arrow.triangle.turn.up.right.diamond"
                    )
                }
                .accessibilityIdentifier("EventLocationDirectionsButton")
            }
        }
    }

    private var destination: DirectionsDestination? {
        DirectionsDestination(
            name: location.title,
            coordinate: location.coordinate.map { PlannerCoordinate(latitude: $0.latitude, longitude: $0.longitude) }
        )
    }

    private func open(_ link: (DirectionsDestination) -> URL?) {
        guard let url = destination.flatMap(link) else { return }
        openURL(url)
    }
}
