import Foundation

/// Mirrors chosen preference keys between local defaults and iCloud key-value storage.
/// iCloud wins at launch and on incoming changes; local edits are pushed as they happen.
@MainActor
public final class SettingsCloudSync {
    public var didApplyCloudChanges: (@MainActor () -> Void)?

    private let domains: [SyncedDefaultsDomain]
    private let cloud: any CloudKeyValueStoring
    private let notificationCenter: NotificationCenter
    private var lastSyncedValues: [String: Any] = [:]
    private var observers: [any NSObjectProtocol] = []

    public init(
        domains: [SyncedDefaultsDomain],
        cloud: any CloudKeyValueStoring = NSUbiquitousKeyValueStore.default,
        notificationCenter: NotificationCenter = .default
    ) {
        self.domains = domains
        self.cloud = cloud
        self.notificationCenter = notificationCenter
    }

    public func start() {
        guard observers.isEmpty else { return }
        observers.append(notificationCenter.addObserver(
            forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            let changedKeys = notification.userInfo?[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String]
            MainActor.assumeIsolated {
                self?.applyCloudValues(for: changedKeys.map(Set.init))
            }
        })
        observers.append(notificationCenter.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.pushLocalChanges()
            }
        })
        cloud.synchronize()
        reconcile()
    }

    public func stop() {
        observers.forEach(notificationCenter.removeObserver)
        observers.removeAll()
    }

    /// Takes iCloud's value where it has one, and uploads local values iCloud doesn't have yet.
    func reconcile() {
        var appliedAny = false
        for domain in domains {
            for key in domain.keys {
                let local = domain.defaults.object(forKey: key)
                if let cloudValue = cloud.object(forKey: key) {
                    lastSyncedValues[key] = cloudValue
                    if !Self.isEqual(local, cloudValue) {
                        domain.defaults.set(cloudValue, forKey: key)
                        appliedAny = true
                    }
                } else if let local {
                    cloud.set(local, forKey: key)
                    lastSyncedValues[key] = local
                }
            }
        }
        if appliedAny {
            didApplyCloudChanges?()
        }
    }

    /// `nil` changed keys means anything may have changed, such as after an iCloud account switch.
    func applyCloudValues(for changedKeys: Set<String>?) {
        var appliedAny = false
        for domain in domains {
            for key in domain.keys where changedKeys?.contains(key) ?? true {
                let cloudValue = cloud.object(forKey: key)
                lastSyncedValues[key] = cloudValue
                guard !Self.isEqual(domain.defaults.object(forKey: key), cloudValue) else { continue }
                domain.defaults.set(cloudValue, forKey: key)
                appliedAny = true
            }
        }
        if appliedAny {
            didApplyCloudChanges?()
        }
    }

    func pushLocalChanges() {
        for domain in domains {
            for key in domain.keys {
                let local = domain.defaults.object(forKey: key)
                guard !Self.isEqual(local, lastSyncedValues[key]) else { continue }
                if let local {
                    cloud.set(local, forKey: key)
                } else {
                    cloud.removeObject(forKey: key)
                }
                lastSyncedValues[key] = local
            }
        }
    }

    private static func isEqual(_ lhs: Any?, _ rhs: Any?) -> Bool {
        switch (lhs, rhs) {
        case (nil, nil): true
        case let (lhs?, rhs?): (lhs as AnyObject).isEqual(rhs)
        default: false
        }
    }
}
