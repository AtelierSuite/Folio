import Foundation
import SwiftData

public struct NoteFileState: Hashable, Sendable {
    public let modifiedDate: Date
    public let isTrashed: Bool
    public let assetNames: [String]
}

extension NoteIndexStore {
    public func fileStates(in location: String) -> [String: NoteFileState] {
        Dictionary(
            fileRecords(in: location).map { record in
                (
                    record.relativePath,
                    NoteFileState(
                        modifiedDate: record.modifiedDate, isTrashed: record.isTrashed, assetNames: record.assetNames
                    )
                )
            },
            uniquingKeysWith: { first, _ in first }
        )
    }

    public func recordFile(_ path: String, in location: String, state: NoteFileState) {
        let records = fileRecords(in: location).filter { $0.relativePath == path }
        if let record = records.first {
            record.modifiedDate = state.modifiedDate
            record.isTrashed = state.isTrashed
            record.assetNames = state.assetNames
            records.dropFirst().forEach(context.delete)
        } else {
            context.insert(NoteFileRecord(
                location: location, relativePath: path, isTrashed: state.isTrashed,
                modifiedDate: state.modifiedDate, assetNames: state.assetNames
            ))
        }
        save()
    }

    /// Forgets every note of `location` that isn't among `paths`, such as notes deleted elsewhere.
    public func keepFiles(_ paths: Set<String>, in location: String) {
        for record in fileRecords(in: location) where !paths.contains(record.relativePath) {
            context.delete(record)
        }
        if context.hasChanges {
            save()
        }
    }

    private func fileRecords(in location: String) -> [NoteFileRecord] {
        (try? context.fetch(FetchDescriptor<NoteFileRecord>(predicate: #Predicate { $0.location == location }))) ?? []
    }
}
