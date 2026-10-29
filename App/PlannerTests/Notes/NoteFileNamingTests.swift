import Foundation
import Testing
@testable import Planner

struct NoteFileNamingTests {
    @Test func sanitizesTitles() {
        #expect(NoteFileNaming.sanitizedTitle("  ..Hidden: name/with\\slashes  ") == "Hidden  name with slashes")
    }

    @Test func mapsICloudPlaceholderNames() {
        #expect(NoteFileNaming.realName(forPlaceholderName: ".Note.md.icloud") == "Note.md")
        #expect(NoteFileNaming.realName(forPlaceholderName: "Note.md") == nil)
        #expect(NoteFileNaming.realName(forPlaceholderName: "..icloud") == nil)
    }

    @Test func namesConflictedCopiesAfterTheNote() {
        let date = Date(timeIntervalSince1970: 1_800_000_000)
        let name = NoteFileNaming.conflictedCopyName(title: "Plan", date: date)
        #expect(name.hasPrefix("Plan"))
        #expect(name.contains("2027-01-"))
        #expect(name.hasSuffix(".md"))
        #expect(!name.contains("ConflictedCopy.Format"))
    }
}
