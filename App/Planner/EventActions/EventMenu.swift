import Foundation

/// The quick actions for an event, in sections. Shared by the context menu, the menu a tap
/// opens and the VoiceOver actions, so all three always offer the same things.
public enum EventMenu {
    public static func sections(for event: CalendarEvent, context: EventMenuContext) -> [[EventMenuItem]] {
        let isWritable = !event.isReadOnly
        var primary: [EventMenuItem] = [.showDetails]
        if let link = event.meetingLink {
            primary.append(.joinMeeting(link))
        }
        if context.isCountingDown {
            primary.append(.stopCountdown)
        } else if context.canStartCountdown {
            primary.append(.startCountdown)
        }
        if context.canRespondToInvitations && event.isInvitation {
            primary.append(.respond)
        }
        var editing: [EventMenuItem] = []
        if isWritable {
            editing.append(.edit)
        }
        if !context.writableCalendars.isEmpty {
            editing.append(.duplicate)
        }
        let destinations = moveDestinations(for: event, context: context)
        if isWritable && !destinations.isEmpty {
            editing.append(.moveToCalendar(destinations))
        }
        editing.append(.copy)
        let notes: [EventMenuItem] = [context.hasLinkedNote ? .openLinkedNote : .createLinkedNote]
        let directions: [EventMenuItem] = EventDirections.url(for: event).map { [.getDirections($0)] } ?? []
        let destructive: [EventMenuItem] = isWritable ? [.delete] : []
        return [primary, editing, notes, directions, destructive].filter { !$0.isEmpty }
    }

    public static func items(for event: CalendarEvent, context: EventMenuContext) -> [EventMenuItem] {
        sections(for: event, context: context).flatMap(\.self)
    }

    /// Events can't move between accounts in EventKit, so only calendars of the same source are offered.
    static func moveDestinations(for event: CalendarEvent, context: EventMenuContext) -> [PlannerCalendar] {
        guard let source = context.eventCalendar?.sourceIdentifier else { return [] }
        return context.writableCalendars.filter {
            $0.sourceIdentifier == source && $0.id != event.calendarIdentifier
        }
    }
}
