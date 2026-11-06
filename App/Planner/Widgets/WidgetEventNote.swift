import Foundation
import SwiftUI

public struct WidgetEventNote: Sendable, Hashable {
    public let event: CalendarEvent
    public let digest: EventNoteDigest
    public let isOngoing: Bool

    public var joinURL: URL? {
        event.meetingLink?.joinDeepLink
    }

    public var meetingBrandColor: Color? {
        event.meetingLink?.provider.brandColor
    }
}

extension CalendarEvent {
    /// The other people on the event, left out when it's only the current user.
    public var visibleAttendees: [EventParticipant] {
        attendees.filter { !$0.isCurrentUser && $0.type == .person }
    }
}

extension WidgetSnapshot {
    public func nextEventNote(at date: Date) -> WidgetEventNote? {
        for event in events where event.endDate > date && !event.isDeclined {
            if let digest = eventNotes[event.reference.storageKey] {
                return WidgetEventNote(event: event, digest: digest, isOngoing: event.startDate <= date)
            }
        }
        return nil
    }
}
