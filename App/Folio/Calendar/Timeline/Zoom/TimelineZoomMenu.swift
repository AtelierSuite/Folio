import SwiftUI

/// Zoom without pinching, for people who can't or prefer not to.
struct TimelineZoomMenu: View {
    let zoom: TimelineZoomController

    var body: some View {
        Menu(String(localized: "Menu", table: "TimelineZoom"), systemImage: "plus.magnifyingglass") {
            Button(String(localized: "ZoomIn", table: "TimelineZoom"), systemImage: "plus.magnifyingglass") {
                withAnimation(.snappy) { zoom.zoomIn() }
            }
            .disabled(!zoom.canZoomIn)
            Button(String(localized: "ZoomOut", table: "TimelineZoom"), systemImage: "minus.magnifyingglass") {
                withAnimation(.snappy) { zoom.zoomOut() }
            }
            .disabled(!zoom.canZoomOut)
            Button(
                String(localized: "FitWholeDay", table: "TimelineZoom"),
                systemImage: "arrow.down.right.and.arrow.up.left"
            ) {
                withAnimation(.snappy) { zoom.fitWholeDay() }
            }
            .disabled(!zoom.canZoomOut)
        }
        .menuActionDismissBehavior(.disabled)
        .accessibilityIdentifier("TimelineZoomMenu")
    }
}
