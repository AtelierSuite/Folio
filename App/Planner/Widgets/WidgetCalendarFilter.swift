import Foundation

/// Which calendars and lists a widget shows: the ones picked in its configuration, or every visible one.
public struct WidgetCalendarFilter: Sendable, Hashable {
    public var selectedIdentifiers: Set<String>?
    public var hiddenIdentifiers: Set<String>

    public init(selectedIdentifiers: Set<String>? = nil, hiddenIdentifiers: Set<String> = []) {
        self.selectedIdentifiers = selectedIdentifiers.flatMap { $0.isEmpty ? nil : $0 }
        self.hiddenIdentifiers = hiddenIdentifiers
    }

    public func includes(_ calendarIdentifier: String) -> Bool {
        if let selectedIdentifiers {
            return selectedIdentifiers.contains(calendarIdentifier)
        }
        return !hiddenIdentifiers.contains(calendarIdentifier)
    }
}
