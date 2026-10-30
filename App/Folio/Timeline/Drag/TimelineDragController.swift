import Observation
import Planner
import SwiftUI

/// Tracks one drag on the timeline. Gestures report pointer locations in `coordinateSpace`,
/// which doesn't scroll, so the proposal follows the content while the timeline auto-scrolls.
@MainActor
@Observable
final class TimelineDragController {
    static let coordinateSpace = NamedCoordinateSpace.named("TimelineDrag")

    private(set) var session: TimelineDragSession?
    private(set) var autoScrollSpeed: CGFloat = 0
    private(set) var edgeDirection: CalendarPageDirection?

    @ObservationIgnored var snap = TimelineDragSnap.default
    @ObservationIgnored var isSuspended = false
    /// Called when a card was lifted and let go without moving, so the screen can show its menu.
    @ObservationIgnored var onReleaseInPlace: ((TimelineEntry) -> Void)?
    @ObservationIgnored var viewportFrame: CGRect = .zero
    /// The part of the grid on screen. The grid itself spans every page, most of them off screen.
    @ObservationIgnored var pagingFrame: CGRect?
    /// Where `coordinateSpace` sits in global coordinates.
    @ObservationIgnored var globalOrigin: CGPoint = .zero
    @ObservationIgnored private(set) var layout: TimelineLayout?
    @ObservationIgnored private var hourHeight: CGFloat = 48
    @ObservationIgnored private var minimumCardHeight: CGFloat = 16
    @ObservationIgnored private var gridFrame: CGRect = .zero
    @ObservationIgnored private var pointer: CGPoint = .zero
    @ObservationIgnored private var startPointer: CGPoint = .zero
    @ObservationIgnored private var lastEndDate = Date.distantPast
    @ObservationIgnored private var hasEnteredGrid = false
    @ObservationIgnored private let autoScroll = TimelineAutoScroll()
    @ObservationIgnored let edgePaging = TimelineEdgePaging()

    #if os(macOS)
    private let handleHeight: CGFloat = 6
    #else
    private let handleHeight: CGFloat = 12
    #endif

    var globalPointer: CGPoint {
        CGPoint(x: pointer.x + globalOrigin.x, y: pointer.y + globalOrigin.y)
    }

    var isActive: Bool {
        session != nil
    }

    /// A card's button also sees the end of a drag as a tap, so selection waits for the drag to settle.
    var suppressesSelection: Bool {
        session != nil || Date.now.timeIntervalSince(lastEndDate) < 0.4
    }

    private var geometry: TimelineGridGeometry {
        TimelineGridGeometry(width: gridFrame.width, dayCount: layout?.days.count ?? 1, hourHeight: hourHeight)
    }

    func update(layout: TimelineLayout, hourHeight: CGFloat, minimumCardHeight: CGFloat) {
        self.layout = layout
        self.hourHeight = hourHeight
        self.minimumCardHeight = minimumCardHeight
        refresh()
    }

    func updateGridFrame(_ frame: CGRect) {
        gridFrame = frame
        refresh()
    }

    func beginMove(at location: CGPoint) -> Bool {
        guard !isSuspended, session == nil, let layout else { return false }
        let gridLocation = gridLocation(of: location)
        guard let target = layout.dragTarget(
            at: gridLocation, geometry: geometry, minimumCardHeight: minimumCardHeight, handleHeight: handleHeight
        ), let origin = geometry.point(at: gridLocation, in: layout.days) else { return false }
        let entry = target.placement.entry
        let original = DateInterval(
            start: target.placement.interval.start,
            duration: max(entry.end.timeIntervalSince(entry.start), 0)
        )
        start(entry: entry, operation: TimelineDragOperation(
            kind: target.kind, original: original, origin: origin, calendar: layout.days.calendar, snap: snap
        ), at: location)
        return true
    }

    func beginPlacing(_ entry: TimelineEntry, at location: CGPoint) -> Bool {
        guard !isSuspended, session == nil, let layout, entry.kind == .reminder, !entry.isReadOnly else { return false }
        let calendar = layout.days.calendar
        let origin = TimelineDragPoint(dayStart: calendar.startOfDay(for: entry.start), hour: 0)
        start(entry: entry, operation: TimelineDragOperation(
            kind: .place(duration: TimelineEntry.reminderDuration),
            original: DateInterval(start: entry.start, end: max(entry.start, entry.end)),
            origin: origin,
            calendar: calendar,
            snap: snap
        ), at: location)
        return true
    }

    func move(to location: CGPoint) {
        pointer = location
        refresh()
    }

    /// Ends the drag. A drop with changes stays on screen as `isDropping` until `finish()`.
    func end() {
        guard var session else { return }
        guard session.hasChanges else {
            finish()
            onReleaseInPlace?(session.entry)
            return
        }
        session.isDropping = true
        self.session = session
        setAutoScrollSpeed(0)
        setEdgeDirection(nil)
    }

    func finish() {
        guard session != nil else { return }
        session = nil
        lastEndDate = .now
        setAutoScrollSpeed(0)
        setEdgeDirection(nil)
    }

    private func start(entry: TimelineEntry, operation: TimelineDragOperation, at location: CGPoint) {
        pointer = location
        startPointer = location
        hasEnteredGrid = false
        session = TimelineDragSession(entry: entry, operation: operation)
        refresh()
    }

    private func gridLocation(of location: CGPoint) -> CGPoint {
        CGPoint(x: location.x - gridFrame.minX, y: location.y - gridFrame.minY)
    }

    private func refresh() {
        guard var session, !session.isDropping, let layout else { return }
        let isPlacing = if case .place = session.operation.kind { true } else { false }
        let isAboveGrid = pointer.y < viewportFrame.minY
        let proposal = (isPlacing && isAboveGrid) ? nil : geometry.point(at: gridLocation(of: pointer), in: layout.days)
            .map(session.operation.interval(at:))
        if proposal != session.proposal {
            session.proposal = proposal
            self.session = session
        }
        let pointerY = pointer.y - viewportFrame.minY
        if pointerY > autoScroll.edgeHeight {
            hasEnteredGrid = true
        }
        // A reminder dragged down from the all-day strip crosses the top band on its way in.
        let speed = (isPlacing && !hasEnteredGrid)
            ? 0 : autoScroll.speed(pointerY: pointerY, viewportHeight: viewportFrame.height)
        setAutoScrollSpeed(speed)
        setEdgeDirection(edgeDirection(for: pointer))
    }

    /// Only once the pointer has moved towards an edge, so grabbing a card that already sits by the edge doesn't page.
    private func edgeDirection(for pointer: CGPoint) -> CalendarPageDirection? {
        let frame = pagingFrame ?? gridFrame
        let direction = edgePaging.direction(pointerX: pointer.x - frame.minX, width: frame.width)
        let travel = pointer.x - startPointer.x
        switch direction {
        case .backward where travel < -edgePaging.edgeWidth: return .backward
        case .forward where travel > edgePaging.edgeWidth: return .forward
        default: return nil
        }
    }

    private func setAutoScrollSpeed(_ speed: CGFloat) {
        if speed != autoScrollSpeed { autoScrollSpeed = speed }
    }

    private func setEdgeDirection(_ direction: CalendarPageDirection?) {
        if direction != edgeDirection { edgeDirection = direction }
    }
}
