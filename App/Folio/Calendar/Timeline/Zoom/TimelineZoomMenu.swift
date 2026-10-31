import SwiftUI

/// Zoom without pinching, for people who can't or prefer not to.
struct TimelineZoomMenu: View {
    let zoom: TimelineZoomController

    var body: some View {
        ControlGroup {
            Button(String(localized: "ZoomOut", table: "TimelineZoom"), systemImage: "minus.magnifyingglass") {
                withAnimation(.snappy) { zoom.zoomOut() }
            }
            .disabled(!zoom.canZoomOut)
            Button(String(localized: "ZoomIn", table: "TimelineZoom"), systemImage: "plus.magnifyingglass") {
                withAnimation(.snappy) { zoom.zoomIn() }
            }
            .disabled(!zoom.canZoomIn)
            Button(
                String(localized: "FitWholeDay", table: "TimelineZoom"),
                systemImage: "arrow.down.right.and.arrow.up.left"
            ) {
                withAnimation(.snappy) { zoom.fitWholeDay() }
            }
            .disabled(!zoom.canZoomOut)
        } label: {
            Label(String(localized: "Menu", table: "TimelineZoom"), systemImage: "plus.magnifyingglass")
        }
        #if os(iOS)
        .menuActionDismissBehavior(.disabled)
        #endif
    }
}
