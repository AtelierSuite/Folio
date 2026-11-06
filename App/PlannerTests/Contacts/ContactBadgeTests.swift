import Foundation
import Testing
@testable import Planner

struct ContactBadgeTests {
    @Test func abbreviatesAFullName() {
        #expect(ContactBadge(name: "Mika Sato").initials == "MS")
    }

    @Test func usesTheFirstLetterOfAnEmailAddress() {
        #expect(ContactBadge(name: "tao@example.com").initials.first == "T")
    }

    @Test func staysEmptyForNoName() {
        #expect(ContactBadge(name: "  ").initials.isEmpty)
    }

    @Test func hasNoImageWithoutAThumbnail() {
        #expect(ContactBadge(initials: "MS").image == nil)
    }
}
