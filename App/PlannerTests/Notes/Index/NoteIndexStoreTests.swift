import Foundation
import SwiftData
import Testing
@testable import Planner

@MainActor
struct NoteIndexStoreTests {
    private let event = NoteLinkEvent(
        eventKey: "event-1", calendarIdentifier: "work", title: "Standup", dayKey: "2026-10-31"
    )
    private let other = NoteLinkEvent(
        eventKey: "event-2", calendarIdentifier: "work", title: "Review", dayKey: "2026-11-01"
    )

    @Test func linksANoteToOneEventAtATime() {
        let store = NoteIndexStore.inMemory()
        store.link(notePath: "a.md", in: "icloud", to: event)
        store.link(notePath: "a.md", in: "icloud", to: other)
        #expect(store.links(in: "icloud").map(\.event) == [other])
        #expect(store.links(in: "device").isEmpty)
    }

    @Test func keepsTheNewestOfDuplicatedLinks() {
        let store = NoteIndexStore.inMemory()
        store.context.insert(NoteLinkRecord(location: "icloud", notePath: "a.md", event: event, linkedAt: .distantPast))
        store.context.insert(NoteLinkRecord(location: "icloud", notePath: "a.md", event: other, linkedAt: .now))
        store.save()
        #expect(store.links(in: "icloud").map(\.event) == [other])
        #expect(store.links(in: "icloud").count == 1)
    }

    @Test func unlinksByNoteOrEventAndFollowsRenames() {
        let store = NoteIndexStore.inMemory()
        store.link(notePath: "a.md", in: "icloud", to: event)
        store.moveLinks(from: "a.md", to: "b.md", in: "icloud")
        #expect(store.links(in: "icloud").map(\.notePath) == ["b.md"])
        #expect(store.unlink(eventKey: "event-1", in: "icloud").map(\.notePath) == ["b.md"])
        #expect(store.links(in: "icloud").isEmpty)
    }

    @Test func remembersFilesAndForgetsMissingOnes() {
        let store = NoteIndexStore.inMemory()
        let state = NoteFileState(modifiedDate: .now, isTrashed: false, assetNames: ["cat.png"])
        store.recordFile("a.md", in: "icloud", state: state)
        store.recordFile("b.md", in: "icloud", state: state)
        store.keepFiles(["a.md"], in: "icloud")
        #expect(store.fileStates(in: "icloud") == ["a.md": state])
    }

    @Test func remembersWhenSomethingWentMissing() {
        let store = NoteIndexStore.inMemory()
        let first = Date(timeIntervalSince1970: 100)
        #expect(store.markMissing("event:1", at: first) == first)
        #expect(store.markMissing("event:1", at: .now) == first)
        store.clearMissing(withPrefix: "event:", except: [])
        #expect(store.markMissing("event:1", at: .now) != first)
    }
}
