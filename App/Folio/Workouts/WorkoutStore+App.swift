import Planner

extension WorkoutStore {
    static func makeForApp() -> WorkoutStore {
        let store = WorkoutStore(capabilities: .current)
        store.startObservingChanges()
        return store
    }
}
