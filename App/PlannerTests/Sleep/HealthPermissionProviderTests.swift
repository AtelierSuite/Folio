import Foundation
import Testing
@testable import Planner

@MainActor
struct HealthPermissionProviderTests {
    private let iPhone = PlatformCapabilities(platform: .iPhone, areLiveActivitiesSupported: true)

    @Test func notDeterminedUntilRequested() async {
        let provider = HealthPermissionProvider(source: FakeSleepDataSource(status: .shouldRequest))
        #expect(await provider.currentStatus() == .notDetermined)
    }

    @Test func unknownAfterRequestBecauseDenialIsHidden() async throws {
        let source = FakeSleepDataSource(status: .shouldRequest)
        let provider = HealthPermissionProvider(source: source)
        #expect(try await provider.requestAccess() == .unknown)
        #expect(source.requestCount == 1)
        #expect(PermissionStatus.unknown.allowsAccess)
        #expect(PermissionStatus.unknown.mayHideMissingAccess)
    }

    @Test func unavailableWithoutHealthData() async {
        let provider = HealthPermissionProvider(source: FakeSleepDataSource(status: .unavailable))
        #expect(await provider.currentStatus() == .unavailable)
    }

    @Test func centerOnlyPromptsOnce() async {
        let source = FakeSleepDataSource(status: .shouldRequest)
        let provider = HealthPermissionProvider(source: source)
        let center = PermissionCenter(providers: [.health: provider], capabilities: iPhone)
        await center.refresh()
        #expect(await center.request(.health) == .unknown)
        #expect(await center.request(.health) == .unknown)
        #expect(source.requestCount == 1)
    }

    @Test func hiddenOnIPadAndMac() {
        for platform in [DevicePlatform.iPad, .mac] {
            let capabilities = PlatformCapabilities(platform: platform, areLiveActivitiesSupported: false)
            let provider = HealthPermissionProvider(source: FakeSleepDataSource())
            let center = PermissionCenter(providers: [.health: provider], capabilities: capabilities)
            #expect(center.status(of: .health) == .unavailable)
        }
    }
}
