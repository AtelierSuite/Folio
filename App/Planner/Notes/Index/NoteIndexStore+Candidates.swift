import Foundation
import SwiftData

extension NoteIndexStore {
    /// Remembers when `key` was first missed and returns that date.
    @discardableResult
    public func markMissing(_ key: String, at date: Date = .now) -> Date {
        if let candidate = candidate(for: key) {
            return candidate.missingSince
        }
        context.insert(NoteRemovalCandidate(key: key, missingSince: date))
        save()
        return date
    }

    public func clearMissing(_ key: String) {
        guard let candidate = candidate(for: key) else { return }
        context.delete(candidate)
        save()
    }

    /// Clears every candidate starting with `prefix` that isn't among `keys`.
    public func clearMissing(withPrefix prefix: String, except keys: Set<String>) {
        let candidates = (try? context.fetch(FetchDescriptor<NoteRemovalCandidate>())) ?? []
        for candidate in candidates where candidate.key.hasPrefix(prefix) && !keys.contains(candidate.key) {
            context.delete(candidate)
        }
        if context.hasChanges {
            save()
        }
    }

    private func candidate(for key: String) -> NoteRemovalCandidate? {
        try? context.fetch(FetchDescriptor<NoteRemovalCandidate>(predicate: #Predicate { $0.key == key })).first
    }
}
