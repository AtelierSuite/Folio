import MapKit
import Planner
import SwiftUI

struct EventLocationMiniMap: View {
    private static let size = CGSize(width: 64, height: 48)

    let coordinate: EventCoordinate
    @Environment(\.colorScheme) private var colorScheme
    @State private var snapshot: Image?

    private struct SnapshotRequest: Hashable {
        let coordinate: EventCoordinate
        let colorScheme: ColorScheme
    }

    var body: some View {
        ZStack {
            if let snapshot {
                snapshot
                    .resizable()
            } else {
                Rectangle()
                    .fill(.quaternary)
            }
            Circle()
                .fill(.red)
                .stroke(.white, lineWidth: 2)
                .frame(width: 12, height: 12)
        }
        .frame(width: Self.size.width, height: Self.size.height)
        .clipShape(.rect(cornerRadius: 10))
        .accessibilityHidden(true)
        .task(id: SnapshotRequest(coordinate: coordinate, colorScheme: colorScheme)) {
            snapshot = await MapSnapshotImage.make(
                at: coordinate,
                size: Self.size,
                colorScheme: colorScheme
            )
        }
    }
}
