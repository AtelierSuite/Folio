import Foundation
import Testing
@testable import Planner

struct SleepSourceKindTests {
    @Test func appleWatchAndIPhoneAreRecognized() {
        #expect(SleepSource.Kind(bundleIdentifier: "com.apple.health.1234", productType: "Watch7,3") == .watch)
        #expect(SleepSource.Kind(bundleIdentifier: "com.apple.health.5678", productType: "iPhone17,1") == .phone)
    }

    @Test func thirdPartyAppsAreOtherEvenOnAWatch() {
        #expect(SleepSource.Kind(bundleIdentifier: "com.example.sleep", productType: "Watch7,3") == .other)
    }

    @Test func unknownAppleDevicesAreOther() {
        #expect(SleepSource.Kind(bundleIdentifier: "com.apple.health.9", productType: nil) == .other)
        #expect(SleepSource.Kind(bundleIdentifier: "com.apple.health.9", productType: "iPad16,3") == .other)
    }
}
