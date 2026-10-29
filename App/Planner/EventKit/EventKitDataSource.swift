import EventKit

public final class EventKitDataSource: CalendarDataSource, @unchecked Sendable {
    public static let shared = EventKitDataSource()

    let eventStore = EKEventStore()

    private init() {}

    public func authorizationStatus(for kind: CalendarItemKind) -> CalendarAuthorizationStatus {
        CalendarAuthorizationStatus(EKEventStore.authorizationStatus(for: kind.entityType))
    }

    public func requestFullAccess(to kind: CalendarItemKind) async throws -> Bool {
        let isGranted = switch kind {
        case .event: try await eventStore.requestFullAccessToEvents()
        case .reminder: try await eventStore.requestFullAccessToReminders()
        }
        if isGranted {
            eventStore.reset()
        }
        return isGranted
    }

    public func calendars(for kind: CalendarItemKind) -> [PlannerCalendar] {
        guard authorizationStatus(for: kind).allowsReading else { return [] }
        return eventStore.calendars(for: kind.entityType).map { PlannerCalendar($0, kind: kind) }
    }

    public func changes() -> AsyncStream<Void> {
        let (stream, continuation) = AsyncStream.makeStream(of: Void.self, bufferingPolicy: .bufferingNewest(1))
        let observer = NotificationCenter.default.addObserver(
            forName: .EKEventStoreChanged,
            object: eventStore,
            queue: nil
        ) { _ in
            continuation.yield()
        }
        let token = ObserverToken(observer)
        continuation.onTermination = { _ in
            NotificationCenter.default.removeObserver(token.observer)
        }
        return stream
    }
}

private struct ObserverToken: @unchecked Sendable {
    let observer: any NSObjectProtocol

    init(_ observer: any NSObjectProtocol) {
        self.observer = observer
    }
}

extension CalendarItemKind {
    var entityType: EKEntityType {
        switch self {
        case .event: .event
        case .reminder: .reminder
        }
    }
}

extension CalendarAuthorizationStatus {
    init(_ status: EKAuthorizationStatus) {
        switch status {
        case .notDetermined: self = .notDetermined
        case .restricted: self = .restricted
        case .denied: self = .denied
        case .writeOnly: self = .writeOnly
        case .fullAccess: self = .fullAccess
        @unknown default: self = .denied
        }
    }
}
