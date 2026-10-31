import Foundation
import SwiftData

/// A note linked to an event, synced through CloudKit. CloudKit needs a default for every property and allows
/// no unique constraints, so two devices can briefly hold duplicates; `NoteIndexStore` keeps the newest.
@Model
public final class NoteLinkRecord {
    public var location: String = ""
    public var notePath: String = ""
    public var eventKey: String = ""
    public var calendarIdentifier: String = ""
    public var eventTitle: String = ""
    public var dayKey: String = ""
    public var linkedAt = Date.distantPast

    init(location: String, notePath: String, event: NoteLinkEvent, linkedAt: Date) {
        self.location = location
        self.notePath = notePath
        self.eventKey = event.eventKey
        self.calendarIdentifier = event.calendarIdentifier
        self.eventTitle = event.title
        self.dayKey = event.dayKey
        self.linkedAt = linkedAt
    }

    var link: NoteLink {
        NoteLink(
            notePath: notePath,
            event: NoteLinkEvent(
                eventKey: eventKey, calendarIdentifier: calendarIdentifier, title: eventTitle, dayKey: dayKey
            ),
            linkedAt: linkedAt
        )
    }
}
