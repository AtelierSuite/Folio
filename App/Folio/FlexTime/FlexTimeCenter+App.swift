import Planner

extension FlexTimeCenter {
    static func makeForApp(
        _ store: CalendarStore,
        _ sleepStore: SleepStore,
        _ scheduler: NotificationScheduler
    ) -> FlexTimeCenter {
        let center = FlexTimeCenter(store: store, sleepStore: sleepStore)
        center.didChange = { await scheduler.replan() }
        return center
    }
}

extension SleepStore {
    static func makeForApp() -> SleepStore {
        let store = SleepStore(capabilities: .current)
        store.startObservingChanges()
        return store
    }
}
