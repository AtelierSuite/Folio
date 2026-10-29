import Foundation

public protocol ArrivalAlertEventPreferences: Sendable {
    func isEnabled(for reference: CalendarItemReference) -> Bool
    func setEnabled(_ isEnabled: Bool, for reference: CalendarItemReference)
}

public struct ArrivalAlertPreferences: ArrivalAlertEventPreferences {
    public static let storageKey = "ArrivalAlerts.Events"

    private let store: CalendarItemMetadataStore<Bool>

    public init(store: CalendarItemMetadataStore<Bool> = CalendarItemMetadataStore(key: storageKey)) {
        self.store = store
    }

    public func isEnabled(for reference: CalendarItemReference) -> Bool {
        store.value(for: reference) ?? false
    }

    public func setEnabled(_ isEnabled: Bool, for reference: CalendarItemReference) {
        store.setValue(isEnabled ? true : nil, for: reference)
    }
}
