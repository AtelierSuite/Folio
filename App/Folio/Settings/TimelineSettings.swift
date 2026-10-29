import Foundation

enum TimelineSettings {
    static let compressesTextKey = "Calendar.Timeline.CompressesText"

    static func zoomKey(for scope: TimelineZoomScope) -> String {
        "Calendar.Timeline.Zoom.\(scope.rawValue)"
    }
}
