import Foundation

public struct CalendarItemMetadataTable<Value: Codable & Sendable>: Codable, Sendable {
    public struct Entry: Codable, Sendable {
        public var reference: CalendarItemReference
        public var value: Value
    }

    public private(set) var entries: [String: Entry] = [:]

    public init() {}

    public func value(for reference: CalendarItemReference) -> Value? {
        matchingEntry(for: reference)?.value
    }

    public mutating func setValue(_ value: Value?, for reference: CalendarItemReference) {
        if let existing = matchingEntry(for: reference) {
            entries.removeValue(forKey: existing.reference.storageKey)
        }
        guard let value else { return }
        entries[reference.storageKey] = Entry(reference: reference, value: value)
    }

    @discardableResult
    public mutating func relink(to reference: CalendarItemReference) -> Value? {
        guard let existing = matchingEntry(for: reference) else { return nil }
        if existing.reference != reference {
            setValue(existing.value, for: reference)
        }
        return existing.value
    }

    private func matchingEntry(for reference: CalendarItemReference) -> Entry? {
        if let exact = entries[reference.storageKey] {
            return exact
        }
        let candidates = entries.values.map(\.reference)
        guard let match = reference.bestMatch(in: candidates) else { return nil }
        return entries[match.storageKey]
    }
}
