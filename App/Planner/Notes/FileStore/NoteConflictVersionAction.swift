import Foundation

enum NoteConflictVersionAction: Equatable {
    case saveConflictedCopy(String)
    case discardIdentical
    case leaveUnresolved

    init(versionText: String?, currentText: String?) {
        guard let versionText else {
            self = .leaveUnresolved
            return
        }
        self = versionText == currentText ? .discardIdentical : .saveConflictedCopy(versionText)
    }

    var resolvesVersion: Bool {
        self != .leaveUnresolved
    }
}
