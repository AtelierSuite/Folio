import Foundation
import SwiftData

extension NoteIndexStore {
    /// One link per note: when devices disagree, the most recent link wins and the others are deleted.
    public func links(in location: String) -> [NoteLink] {
        var newest: [String: NoteLinkRecord] = [:]
        for record in linkRecords(in: location) {
            guard let current = newest[record.notePath] else {
                newest[record.notePath] = record
                continue
            }
            let (keep, drop) = record.linkedAt > current.linkedAt ? (record, current) : (current, record)
            newest[record.notePath] = keep
            context.delete(drop)
        }
        if context.hasChanges {
            save()
        }
        return newest.values.map(\.link)
    }

    public func link(notePath: String, in location: String, to event: NoteLinkEvent, at date: Date = .now) {
        for record in linkRecords(in: location, notePath: notePath) {
            context.delete(record)
        }
        context.insert(NoteLinkRecord(location: location, notePath: notePath, event: event, linkedAt: date))
        save()
    }

    @discardableResult
    public func unlink(notePath: String, in location: String) -> [NoteLink] {
        let records = linkRecords(in: location, notePath: notePath)
        let links = records.map(\.link)
        records.forEach(context.delete)
        save()
        return links
    }

    @discardableResult
    public func unlink(eventKey: String, in location: String) -> [NoteLink] {
        let records = linkRecords(in: location).filter { $0.eventKey == eventKey }
        let links = records.map(\.link)
        records.forEach(context.delete)
        save()
        return links
    }

    public func moveLinks(from oldPath: String, to newPath: String, in location: String) {
        for record in linkRecords(in: location, notePath: oldPath) {
            record.notePath = newPath
        }
        save()
    }

    /// Fills in what older links didn't record, such as the calendar, once the event has been found.
    public func updateEvent(_ event: NoteLinkEvent, in location: String) {
        for record in linkRecords(in: location) where record.eventKey == event.eventKey {
            if record.calendarIdentifier != event.calendarIdentifier || record.eventTitle != event.title {
                record.calendarIdentifier = event.calendarIdentifier
                record.eventTitle = event.title
            }
        }
        if context.hasChanges {
            save()
        }
    }

    private func linkRecords(in location: String, notePath: String? = nil) -> [NoteLinkRecord] {
        let descriptor = if let notePath {
            FetchDescriptor<NoteLinkRecord>(
                predicate: #Predicate { $0.location == location && $0.notePath == notePath }
            )
        } else {
            FetchDescriptor<NoteLinkRecord>(predicate: #Predicate { $0.location == location })
        }
        return (try? context.fetch(descriptor)) ?? []
    }
}
