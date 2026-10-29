import Planner

struct SleepSummary {
    let lastNight: SleepSession?
    let sources: [SleepSource]

    init(store: SleepStore) async {
        lastNight = await store.lastNight()
        sources = await store.recentSources()
    }
}
