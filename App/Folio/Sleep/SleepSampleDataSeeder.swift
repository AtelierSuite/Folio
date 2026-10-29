#if DEBUG
import Planner
import SwiftUI

enum SleepSampleDataSeeder {
    static func seedIfRequested(into store: SleepStore, arguments: [String]) async {
        #if os(iOS)
        guard arguments.contains(SleepSampleData.launchArgument), store.isAvailable else { return }
        try? await HealthKitSleepDataSource().writeSampleData()
        store.invalidate()
        #endif
    }
}
#endif
