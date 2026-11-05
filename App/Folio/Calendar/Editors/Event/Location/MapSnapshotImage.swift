import MapKit
import Planner
import SwiftUI

enum MapSnapshotImage {
    static func make(at coordinate: EventCoordinate, size: CGSize, colorScheme: ColorScheme) async -> Image? {
        let options = MKMapSnapshotter.Options()
        options.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude),
            latitudinalMeters: 500,
            longitudinalMeters: 500
        )
        options.size = size
        options.pointOfInterestFilter = .excludingAll
        #if os(macOS)
        options.appearance = NSAppearance(named: colorScheme == .dark ? .darkAqua : .aqua)
        #else
        options.traitCollection = UITraitCollection(userInterfaceStyle: colorScheme == .dark ? .dark : .light)
        #endif
        guard let snapshot = try? await MKMapSnapshotter(options: options).start() else { return nil }
        #if os(macOS)
        return Image(nsImage: snapshot.image)
        #else
        return Image(uiImage: snapshot.image)
        #endif
    }
}
