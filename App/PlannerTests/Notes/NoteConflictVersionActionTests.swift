import Foundation
import Testing
@testable import Planner

struct NoteConflictVersionActionTests {
    @Test func leavesUnreadableVersionsUnresolved() {
        let action = NoteConflictVersionAction(versionText: nil, currentText: "Mine")
        #expect(action == .leaveUnresolved)
        #expect(!action.resolvesVersion)
    }

    @Test func discardsVersionsIdenticalToTheCurrentText() {
        let action = NoteConflictVersionAction(versionText: "Same", currentText: "Same")
        #expect(action == .discardIdentical)
        #expect(action.resolvesVersion)
    }

    @Test func savesDifferingVersionsAsConflictedCopies() {
        let action = NoteConflictVersionAction(versionText: "Theirs", currentText: "Mine")
        #expect(action == .saveConflictedCopy("Theirs"))
        #expect(action.resolvesVersion)
    }

    @Test func savesVersionsWhenTheCurrentTextIsUnreadable() {
        let action = NoteConflictVersionAction(versionText: "Theirs", currentText: nil)
        #expect(action == .saveConflictedCopy("Theirs"))
    }
}
