import Foundation
import Observation

/// Sheets cover the window's toast on iPhone, so every presented sheet hosts the toast too
/// and only the most recently presented host shows it.
@MainActor
@Observable
final class UndoToastHosts {
    private(set) var hostIdentifiers: [UUID] = []

    var topHostIdentifier: UUID? {
        hostIdentifiers.last
    }

    func add(_ identifier: UUID) {
        hostIdentifiers.removeAll { $0 == identifier }
        hostIdentifiers.append(identifier)
    }

    func remove(_ identifier: UUID) {
        hostIdentifiers.removeAll { $0 == identifier }
    }
}
