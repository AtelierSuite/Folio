import Foundation
import Testing
@testable import Planner

struct MeetingLinkCacheTests {
    @Test func cachesDetectionsIncludingMisses() {
        let cache = MeetingLinkCache()
        let meeting = MeetingLinkSource(url: nil, location: "https://zoom.us/j/1", notes: nil)
        let plain = MeetingLinkSource(url: nil, location: "Room 4", notes: nil)
        #expect(cache.link(for: meeting)?.provider == .zoom)
        #expect(cache.link(for: plain) == nil)
        #expect(cache.link(for: meeting)?.provider == .zoom)
        #expect(cache.count == 2)
    }

    @Test func startsOverWhenFull() {
        let cache = MeetingLinkCache(entryLimit: 2)
        for number in 0..<3 {
            _ = cache.link(for: MeetingLinkSource(url: nil, location: "Room \(number)", notes: nil))
        }
        #expect(cache.count == 1)
    }
}
