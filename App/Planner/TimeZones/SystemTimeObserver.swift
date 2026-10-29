import Foundation
import Observation

/// Follows the system time zone, clock and date so every view and the notification scheduler
/// can update when the user travels or changes the time.
@MainActor
@Observable
public final class SystemTimeObserver {
    public nonisolated static let changeNotifications: [Notification.Name] = [
        .NSSystemTimeZoneDidChange,
        .NSSystemClockDidChange,
        .NSCalendarDayChanged
    ]

    public private(set) var calendar: Calendar
    public private(set) var changeCount = 0

    @ObservationIgnored private let notificationCenter: NotificationCenter
    @ObservationIgnored private let currentCalendar: @Sendable () -> Calendar
    @ObservationIgnored private var observation: Task<Void, Never>?
    @ObservationIgnored private var onChange: (@MainActor () async -> Void)?

    public init(
        notificationCenter: NotificationCenter = .default,
        currentCalendar: @escaping @Sendable () -> Calendar = SystemTimeObserver.systemCalendar
    ) {
        self.notificationCenter = notificationCenter
        self.currentCalendar = currentCalendar
        calendar = currentCalendar()
    }

    public var timeZone: TimeZone {
        calendar.timeZone
    }

    /// Only the first call starts observing, so a second window can't register `onChange` twice.
    public func startObserving(onChange: @escaping @MainActor () async -> Void = {}) {
        guard observation == nil else { return }
        self.onChange = onChange
        let changes = Self.changes(in: notificationCenter)
        observation = Task { [weak self] in
            for await _ in changes where !Task.isCancelled {
                await self?.systemTimeDidChange()
            }
        }
    }

    public func stopObserving() {
        observation?.cancel()
        observation = nil
        onChange = nil
    }

    func systemTimeDidChange() async {
        calendar = currentCalendar()
        changeCount += 1
        await onChange?()
    }

    /// Foundation caches the system time zone until it is reset.
    public nonisolated static func systemCalendar() -> Calendar {
        NSTimeZone.resetSystemTimeZone()
        var calendar = Calendar.current
        calendar.timeZone = .current
        return calendar
    }

    private nonisolated static func changes(in notificationCenter: NotificationCenter) -> AsyncStream<Void> {
        let (stream, continuation) = AsyncStream.makeStream(of: Void.self, bufferingPolicy: .bufferingNewest(1))
        let observers = changeNotifications.map { name in
            notificationCenter.addObserver(forName: name, object: nil, queue: nil) { _ in
                continuation.yield()
            }
        }
        let tokens = SystemTimeObserverTokens(observers: observers, notificationCenter: notificationCenter)
        continuation.onTermination = { _ in
            tokens.removeAll()
        }
        return stream
    }
}

private struct SystemTimeObserverTokens: @unchecked Sendable {
    let observers: [any NSObjectProtocol]
    let notificationCenter: NotificationCenter

    func removeAll() {
        observers.forEach(notificationCenter.removeObserver)
    }
}
