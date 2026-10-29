import Foundation
import Synchronization

/// Cards ask for an event's meeting link on every render, so detection runs once per distinct text.
final class MeetingLinkCache: Sendable {
    static let shared = MeetingLinkCache()

    private let entryLimit: Int
    private let entries = Mutex<[MeetingLinkSource: MeetingLink?]>([:])

    init(entryLimit: Int = 1000) {
        self.entryLimit = entryLimit
    }

    func link(for source: MeetingLinkSource) -> MeetingLink? {
        if let cached = entries.withLock({ $0[source] }) {
            return cached
        }
        let detected = MeetingLinkDetector.link(url: source.url, texts: [source.location, source.notes])
        entries.withLock { entries in
            if entries.count >= entryLimit {
                entries.removeAll(keepingCapacity: true)
            }
            entries[source] = .some(detected)
        }
        return detected
    }

    var count: Int {
        entries.withLock { $0.count }
    }
}
