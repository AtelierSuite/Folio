import Planner

extension MedicationStore {
    static func makeForApp(notificationScheduler: NotificationScheduler) -> MedicationStore {
        let store = MedicationStore(capabilities: .current)
        store.allowsReminders = { [weak notificationScheduler] in notificationScheduler?.isEnabled == true }
        store.startObservingChanges()
        return store
    }
}
