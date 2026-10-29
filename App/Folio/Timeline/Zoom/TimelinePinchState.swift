import Observation
import SwiftUI

/// Only `scale` and `anchor` are observed, so a pinch redraws the scale effect and nothing else.
@MainActor
@Observable
final class TimelinePinchState {
    var scale: CGFloat = 1
    var anchor: CGFloat = 0.5
    @ObservationIgnored var isActive = false
    @ObservationIgnored var baseMagnification: CGFloat = 1
    @ObservationIgnored var anchorContentY: CGFloat?
    @ObservationIgnored var scrollOffset: CGFloat = 0
    @ObservationIgnored var viewportHeight: CGFloat = 0
}
