import Foundation
import Testing
@testable import Planner

struct OnboardingDeepLinkTests {
    @Test func recognizesOnlyTheReonboardLink() throws {
        #expect(OnboardingDeepLink.url.absoluteString == "folio://reonboard")
        #expect(OnboardingDeepLink.isReonboard(OnboardingDeepLink.url))
        #expect(OnboardingDeepLink.isReonboard(try #require(URL(string: "FOLIO://ReOnboard"))))
        #expect(!OnboardingDeepLink.isReonboard(try #require(URL(string: "folio://new/note"))))
        #expect(!OnboardingDeepLink.isReonboard(try #require(URL(string: "https://reonboard"))))
    }
}
