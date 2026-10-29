#if DEBUG
import OSLog
import Planner
import SwiftUI

enum SleepSampleDataSeeder {
    static func seedIfRequested(into store: SleepStore, arguments: [String]) async {
        #if os(iOS)
        guard arguments.contains(SleepSampleData.launchArgument), store.isAvailable else { return }
        do {
            try await HealthKitSleepDataSource().writeSampleData()
        } catch {
            Logger(subsystem: "com.tsubuzaki.Folio", category: "Sleep")
                .error("Writing sample sleep failed: \(error.localizedDescription, privacy: .public)")
        }
        store.invalidate()
        #endif
    }
}
#endif
