import Foundation
import Observation

@MainActor
@Observable
public final class TravelTimeStore {
    public private(set) var isEnabled: Bool
    public private(set) var transport: TravelTransport
    public private(set) var firstEventOrigin: TravelOrigin
    public private(set) var startingLocation: EventLocation?
    /// Bumped whenever a setting changes what views should show, so they reload.
    public private(set) var revision = 0

    @ObservationIgnored let settings: TravelTimeSettings
    @ObservationIgnored let locator: (any CurrentLocating)?
    @ObservationIgnored let resolver: EventCoordinateResolver
    @ObservationIgnored let estimator: any TravelTimeEstimating
    @ObservationIgnored let planner: TravelTimePlanner
    @ObservationIgnored let now: () -> Date
    @ObservationIgnored var cachedEstimates: [CachedEstimateKey: CachedEstimate] = [:]
    @ObservationIgnored var resolvedStartingLocations: [EventLocation: PlannerCoordinate] = [:]
    @ObservationIgnored let estimateLifetime: TimeInterval = 10 * 60
    @ObservationIgnored let originTolerance: Double = 500

    public init(
        settings: TravelTimeSettings = TravelTimeSettings(),
        locator: (any CurrentLocating)? = CurrentLocationProvider.shared,
        resolver: EventCoordinateResolver = EventCoordinateResolver(),
        estimator: any TravelTimeEstimating = MapKitTravelTimeEstimator(),
        planner: TravelTimePlanner = TravelTimePlanner(),
        now: @escaping () -> Date = { .now }
    ) {
        self.settings = settings
        self.locator = locator
        self.resolver = resolver
        self.estimator = estimator
        self.planner = planner
        self.now = now
        isEnabled = settings.isEnabled
        transport = settings.transport
        firstEventOrigin = settings.firstEventOrigin
        startingLocation = settings.startingLocation
    }

    public func setEnabled(_ isEnabled: Bool) {
        settings.isEnabled = isEnabled
        self.isEnabled = isEnabled
        revision += 1
    }

    public func setTransport(_ transport: TravelTransport) {
        settings.transport = transport
        self.transport = transport
        revision += 1
    }

    public func setFirstEventOrigin(_ firstEventOrigin: TravelOrigin) {
        settings.firstEventOrigin = firstEventOrigin
        self.firstEventOrigin = firstEventOrigin
        revision += 1
    }

    public func setStartingLocation(_ startingLocation: EventLocation?) {
        settings.startingLocation = startingLocation
        self.startingLocation = startingLocation
        revision += 1
    }

    public func locationAuthorizationDidChange() {
        revision += 1
    }

    public func reloadSettings() {
        isEnabled = settings.isEnabled
        transport = settings.transport
        firstEventOrigin = settings.firstEventOrigin
        startingLocation = settings.startingLocation
        revision += 1
    }

    public var hasLocationAccess: Bool {
        locator?.authorizationStatus == .granted
    }
}
