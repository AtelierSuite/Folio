import Planner
import SwiftUI

/// The timeline's vertical scroll view. With a `zoom` controller it pinches to zoom and keeps the
/// hour under the fingers (or the middle of the view for buttons and menu items) in place.
struct TimelineZoomScrollView<Content: View>: View {
    let zoom: TimelineZoomController?
    let fixedHourHeight: CGFloat
    let initialHour: Double
    let verticalInset: CGFloat
    @ViewBuilder let content: (CGFloat) -> Content

    @State private var pinch = TimelinePinchState()
    @State private var position = ScrollPosition(idType: Int.self)

    private var hourHeight: CGFloat {
        zoom?.hourHeight ?? fixedHourHeight
    }

    private var anchor: TimelineZoomAnchor {
        TimelineZoomAnchor(verticalInset: verticalInset, viewportHeight: pinch.viewportHeight)
    }

    var body: some View {
        ScrollView(.vertical) {
            content(hourHeight)
                .modifier(TimelinePinchScaleModifier(pinch: pinch))
                .simultaneousGesture(magnifyGesture, isEnabled: zoom != nil)
        }
        .scrollPosition($position)
        .modifier(TimelineDragAutoScrollModifier(
            position: $position, pinch: pinch, contentHeight: hourHeight * 24 + verticalInset * 2
        ))
        .accessibilityIdentifier("TimelineScrollView")
        .defaultScrollAnchor(UnitPoint(x: 0, y: initialHour / 24), for: .initialOffset)
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            geometry.contentOffset.y + geometry.contentInsets.top
        } action: { _, offset in
            pinch.scrollOffset = offset
        }
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            geometry.containerSize.height
        } action: { _, height in
            pinch.viewportHeight = height
            zoom?.updateViewport(height: height, verticalInset: verticalInset)
        }
        .onChange(of: hourHeight) { oldHeight, newHeight in
            keepAnchor(from: oldHeight, to: newHeight)
        }
    }

    private var magnifyGesture: some Gesture {
        MagnifyGesture(minimumScaleDelta: 0.02)
            .onChanged { value in
                guard let zoom else { return }
                if !pinch.isActive {
                    begin(atContentY: value.startLocation.y)
                }
                let liveHeight = zoom.clamped(hourHeight * value.magnification / pinch.baseMagnification)
                if zoom.detailStep(for: liveHeight) != zoom.detailStep(for: hourHeight) {
                    pinch.baseMagnification = value.magnification
                    pinch.scale = 1
                    zoom.setHourHeight(liveHeight)
                } else {
                    pinch.scale = liveHeight / hourHeight
                }
            }
            .onEnded { value in
                guard let zoom, pinch.isActive else { return }
                let previousHeight = hourHeight
                pinch.scale = 1
                pinch.isActive = false
                zoom.isPinching = false
                zoom.setHourHeight(hourHeight * value.magnification / pinch.baseMagnification)
                if hourHeight == previousHeight {
                    pinch.anchorContentY = nil
                }
            }
    }

    /// The gesture sits on the scroll content, so its location is already in content coordinates.
    private func begin(atContentY contentY: CGFloat) {
        pinch.isActive = true
        pinch.baseMagnification = 1
        pinch.anchorContentY = contentY
        pinch.anchor = anchor.scaleAnchor(contentY: contentY, hourHeight: hourHeight)
        zoom?.isPinching = true
    }

    private func keepAnchor(from oldHeight: CGFloat, to newHeight: CGFloat) {
        let contentY = pinch.anchorContentY ?? pinch.scrollOffset + pinch.viewportHeight / 2
        let viewportY = contentY - pinch.scrollOffset
        let offset = anchor.scrollOffset(
            keepingContentY: contentY, atViewportY: viewportY, from: oldHeight, to: newHeight
        )
        position.scrollTo(y: offset)
        pinch.scrollOffset = offset
        guard pinch.isActive else {
            pinch.anchorContentY = nil
            return
        }
        let newContentY = anchor.contentY(
            ofHour: anchor.hour(atContentY: contentY, hourHeight: oldHeight), hourHeight: newHeight
        )
        pinch.anchorContentY = newContentY
        pinch.anchor = anchor.scaleAnchor(contentY: newContentY, hourHeight: newHeight)
    }
}
