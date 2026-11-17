import Foundation
import Testing
@testable import Planner

@MainActor
struct SettingsCloudSyncTests {
    private final class FakeCloudStore: CloudKeyValueStoring {
        var values: [String: Any] = [:]

        func object(forKey key: String) -> Any? { values[key] }
        func set(_ value: Any?, forKey key: String) { values[key] = value }
        func removeObject(forKey key: String) { values[key] = nil }
        func synchronize() -> Bool { true }
    }

    private let defaults: UserDefaults
    private let cloud = FakeCloudStore()
    private let sync: SettingsCloudSync

    init() {
        let suiteName = "SettingsCloudSyncTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName) ?? .standard
        defaults.removePersistentDomain(forName: suiteName)
        sync = SettingsCloudSync(
            domains: [SyncedDefaultsDomain(defaults: defaults, keys: ["Synced", "Other"])],
            cloud: cloud,
            notificationCenter: NotificationCenter()
        )
    }

    @Test func launchTakesTheCloudValue() {
        defaults.set(10, forKey: "Synced")
        cloud.values["Synced"] = 20
        sync.reconcile()
        #expect(defaults.integer(forKey: "Synced") == 20)
    }

    @Test func launchUploadsLocalValuesTheCloudLacks() {
        defaults.set(true, forKey: "Synced")
        sync.reconcile()
        #expect(cloud.values["Synced"] as? Bool == true)
    }

    @Test func leavesKeysOutsideTheListAlone() {
        defaults.set("local", forKey: "Unsynced")
        cloud.values["Unsynced"] = "cloud"
        sync.reconcile()
        sync.pushLocalChanges()
        #expect(defaults.string(forKey: "Unsynced") == "local")
        #expect(cloud.values["Unsynced"] as? String == "cloud")
    }

    @Test func pushesOnlyChangedKeys() {
        cloud.values["Other"] = "remote"
        sync.reconcile()
        cloud.values["Other"] = "newer remote"
        defaults.set(5, forKey: "Synced")
        sync.pushLocalChanges()
        #expect(cloud.values["Synced"] as? Int == 5)
        #expect(cloud.values["Other"] as? String == "newer remote")
    }

    @Test func pushesRemovals() {
        defaults.set(5, forKey: "Synced")
        sync.reconcile()
        defaults.removeObject(forKey: "Synced")
        sync.pushLocalChanges()
        #expect(cloud.values["Synced"] == nil)
    }

    @Test func appliesIncomingChangesAndRemovals() {
        defaults.set(5, forKey: "Synced")
        defaults.set("old", forKey: "Other")
        sync.reconcile()
        cloud.values["Synced"] = 8
        cloud.values["Other"] = nil
        var notified = 0
        sync.didApplyCloudChanges = { notified += 1 }
        sync.applyCloudValues(for: ["Synced", "Other"])
        #expect(defaults.integer(forKey: "Synced") == 8)
        #expect(defaults.object(forKey: "Other") == nil)
        #expect(notified == 1)
    }

    @Test func incomingChangesAreNotPushedBack() {
        sync.reconcile()
        cloud.values["Synced"] = Data([1, 2, 3])
        sync.applyCloudValues(for: nil)
        cloud.values["Synced"] = Data([4])
        sync.pushLocalChanges()
        #expect(cloud.values["Synced"] as? Data == Data([4]))
    }

    @Test func unchangedIncomingValuesDoNotNotify() {
        defaults.set(["a": 1.0], forKey: "Synced")
        sync.reconcile()
        var notified = false
        sync.didApplyCloudChanges = { notified = true }
        sync.applyCloudValues(for: ["Synced"])
        #expect(!notified)
    }

    @Test func reportsChangesThatArrivedBeforeAnyoneListened() {
        cloud.values["Synced"] = 3
        sync.reconcile()
        var notified = 0
        sync.didApplyCloudChanges = { notified += 1 }
        sync.didApplyCloudChanges = { notified += 1 }
        #expect(notified == 1)
    }
}
