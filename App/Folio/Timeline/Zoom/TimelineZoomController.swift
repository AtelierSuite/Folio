import Observation
import Planner
import SwiftUI

@MainActor
@Observable
final class TimelineZoomController {
    @ObservationIgnored private let zoom = TimelineZoom()
    @ObservationIgnored private let storageKey: String?
    @ObservationIgnored private let defaults: UserDefaults
    private(set) var level: TimelineZoomLevel
    private(set) var fittingHourHeight: CGFloat?
    var isPinching = false

    init(storageKey: String?, defaults: UserDefaults = .standard) {
        self.storageKey = storageKey
        self.defaults = defaults
        let storedValue = storageKey.flatMap { key in
            defaults.object(forKey: key).map { _ in defaults.double(forKey: key) }
        }
        level = storedValue.map(TimelineZoomLevel.init(storedValue:)) ?? .hourHeight(TimelineZoom().defaultHourHeight)
    }

    var hourHeight: CGFloat {
        if let fittingHourHeight {
            return zoom.hourHeight(for: level, fitting: fittingHourHeight)
        }
        guard case .hourHeight(let hourHeight) = level else { return zoom.defaultHourHeight }
        return min(hourHeight, zoom.maximumHourHeight)
    }

    var canZoomIn: Bool {
        zoom.canZoomIn(from: hourHeight)
    }

    var canZoomOut: Bool {
        guard let fittingHourHeight else { return level != .fitsWholeDay }
        return zoom.canZoomOut(from: hourHeight, fitting: fittingHourHeight)
    }

    func clamped(_ hourHeight: CGFloat) -> CGFloat {
        zoom.clamped(hourHeight, fitting: fittingHourHeight ?? 1)
    }

    func detailStep(for hourHeight: CGFloat) -> Int {
        zoom.detailStep(for: hourHeight)
    }

    func setHourHeight(_ hourHeight: CGFloat) {
        store(zoom.level(for: clamped(hourHeight), fitting: fittingHourHeight ?? 0))
    }

    func zoomIn() {
        setHourHeight(zoom.zoomedIn(from: hourHeight, fitting: fittingHourHeight ?? 1))
    }

    func zoomOut() {
        setHourHeight(zoom.zoomedOut(from: hourHeight, fitting: fittingHourHeight ?? 1))
    }

    func fitWholeDay() {
        store(.fitsWholeDay)
    }

    func updateViewport(height: CGFloat, verticalInset: CGFloat) {
        guard height > 0 else { return }
        let fitting = zoom.fittingHourHeight(viewportHeight: height, verticalInset: verticalInset)
        if fitting != fittingHourHeight {
            fittingHourHeight = fitting
        }
    }

    private func store(_ newLevel: TimelineZoomLevel) {
        guard newLevel != level else { return }
        level = newLevel
        if let storageKey {
            defaults.set(newLevel.storedValue, forKey: storageKey)
        }
    }
}
