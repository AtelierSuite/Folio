import Foundation
import Synchronization
@testable import Planner

final class FakeGeocoder: LocationGeocoding {
    struct Failure: Error {}

    private let results: Mutex<[String: PlannerCoordinate]>
    private let failing: Bool
    private let queries = Mutex<[String]>([])

    init(results: [String: PlannerCoordinate] = [:], failing: Bool = false) {
        self.results = Mutex(results)
        self.failing = failing
    }

    var requestedQueries: [String] {
        queries.withLock { $0 }
    }

    func coordinate(for address: String) async throws -> PlannerCoordinate? {
        queries.withLock { $0.append(address) }
        if failing {
            throw Failure()
        }
        return results.withLock { $0[address] }
    }
}

final class InMemoryGeocodeCache: GeocodeCache {
    private let entries = Mutex<[String: GeocodedLocation]>([:])

    func geocodedLocation(for reference: CalendarItemReference) -> GeocodedLocation? {
        entries.withLock { $0[reference.storageKey] }
    }

    func store(_ location: GeocodedLocation, for reference: CalendarItemReference) {
        entries.withLock { $0[reference.storageKey] = location }
    }
}

final class InMemoryArrivalPreferences: ArrivalAlertEventPreferences {
    private let enabled: Mutex<Set<String>>

    init(enabled: Set<String> = []) {
        self.enabled = Mutex(enabled)
    }

    func isEnabled(for reference: CalendarItemReference) -> Bool {
        enabled.withLock { $0.contains(reference.storageKey) }
    }

    func setEnabled(_ isEnabled: Bool, for reference: CalendarItemReference) {
        enabled.withLock { set in
            if isEnabled {
                set.insert(reference.storageKey)
            } else {
                set.remove(reference.storageKey)
            }
        }
    }
}

final class RecordingArrivalNotifier: ArrivalNotifying {
    private let notified = Mutex<[ArrivalCandidate]>([])

    var notifiedTitles: [String] {
        notified.withLock { $0.map(\.event.title) }
    }

    func notify(_ candidate: ArrivalCandidate, at date: Date) async {
        notified.withLock { $0.append(candidate) }
    }
}

@MainActor
final class FakeRegionMonitor: RegionMonitoring {
    var authorization: ArrivalAuthorization
    var lastKnownCoordinate: PlannerCoordinate?
    var onAuthorizationChange: (@MainActor () -> Void)?
    private(set) var monitored: [String: ArrivalRegion] = [:]
    private(set) var maximumMonitoredCount = 0
    private(set) var authorizationRequestCount = 0
    private var continuation: AsyncStream<RegionArrival>.Continuation?

    init(authorization: ArrivalAuthorization = .always) {
        self.authorization = authorization
    }

    func requestAuthorization() {
        authorizationRequestCount += 1
    }

    func monitoredIdentifiers() async -> [String] {
        Array(monitored.keys)
    }

    func startMonitoring(_ region: ArrivalRegion) async {
        monitored[region.id] = region
        maximumMonitoredCount = max(maximumMonitoredCount, monitored.count)
    }

    func stopMonitoring(_ identifier: String) async {
        monitored[identifier] = nil
    }

    func arrivals() -> AsyncStream<RegionArrival> {
        let (stream, continuation) = AsyncStream<RegionArrival>.makeStream()
        self.continuation = continuation
        return stream
    }

    func grantAuthorization(_ authorization: ArrivalAuthorization) {
        self.authorization = authorization
        onAuthorizationChange?()
    }
}

enum ArrivalFixtures {
    static let now = Fixtures.date(2026, 10, 29, hour: 9)
    static let office = PlannerCoordinate(latitude: 35.681, longitude: 139.767)

    static func hours(_ hours: Double) -> Date {
        now.addingTimeInterval(hours * 3600)
    }

    static func coordinate(_ index: Int) -> PlannerCoordinate {
        PlannerCoordinate(latitude: 35 + Double(index) * 0.01, longitude: 139)
    }

    static func event(
        _ title: String,
        start: Date,
        hours: Double = 1,
        coordinate: PlannerCoordinate? = office,
        location: String? = nil,
        isAllDay: Bool = false
    ) -> CalendarEvent {
        let base = Fixtures.event(local: title, start: start, hours: hours)
        return CalendarEvent(
            reference: base.reference,
            calendarIdentifier: base.calendarIdentifier,
            title: title,
            location: location,
            coordinate: coordinate,
            startDate: base.startDate,
            endDate: base.endDate,
            isAllDay: isAllDay
        )
    }

    static func candidate(_ event: CalendarEvent) -> ArrivalCandidate? {
        event.coordinate.flatMap { ArrivalRegionPlanner().candidate(for: event, at: $0) }
    }
}
