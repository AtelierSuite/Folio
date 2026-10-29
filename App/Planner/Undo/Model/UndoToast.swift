import Foundation

public struct UndoToast: Identifiable, Sendable, Hashable {
    public let id: UUID
    public let action: UndoAction
}
