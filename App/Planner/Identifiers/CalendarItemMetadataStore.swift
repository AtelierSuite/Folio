import Foundation
import Synchronization

public final class CalendarItemMetadataStore<Value: Codable & Sendable>: Sendable {
    private let key: String
    private nonisolated(unsafe) let defaults: UserDefaults
    private let table: Mutex<CalendarItemMetadataTable<Value>>

    public init(key: String, defaults: UserDefaults = AppGroup.userDefaults) {
        self.key = key
        self.defaults = defaults
        let stored = defaults.data(forKey: key)
            .flatMap { try? JSONDecoder().decode(CalendarItemMetadataTable<Value>.self, from: $0) }
        table = Mutex(stored ?? CalendarItemMetadataTable())
    }

    public func value(for reference: CalendarItemReference) -> Value? {
        let (value, changed) = table.withLock { table in
            let isStoredUnderReference = table.entries[reference.storageKey]?.reference == reference
            let value = table.relink(to: reference)
            return (value, value != nil && !isStoredUnderReference)
        }
        if changed {
            save()
        }
        return value
    }

    public func setValue(_ value: Value?, for reference: CalendarItemReference) {
        table.withLock { $0.setValue(value, for: reference) }
        save()
    }

    private func save() {
        let data = table.withLock { try? JSONEncoder().encode($0) }
        defaults.set(data, forKey: key)
    }
}
