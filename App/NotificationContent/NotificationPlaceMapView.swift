import MapKit
import Planner
import SwiftUI

struct NotificationPlaceMapView: View {
    let coordinate: PlannerCoordinate
    let name: String?
    let accentColor: Color

    var body: some View {
        Map(initialPosition: .region(region), interactionModes: []) {
            Marker(name ?? "", coordinate: center)
                .tint(accentColor)
        }
        .frame(height: 160)
        .clipShape(.rect(cornerRadius: 12))
        .accessibilityHidden(true)
        .accessibilityIdentifier("NotificationDetail.Map")
    }

    private var center: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }

    private var region: MKCoordinateRegion {
        MKCoordinateRegion(center: center, latitudinalMeters: 800, longitudinalMeters: 800)
    }
}
