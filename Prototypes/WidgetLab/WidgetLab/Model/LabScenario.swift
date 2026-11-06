import SwiftUI

enum LabScenario: String, CaseIterable, Identifiable {
    case busy = "Busy"
    case light = "Light"
    case empty = "Empty"

    var id: String { rawValue }

    func snapshot(minuteOfDay: Int) -> LabSnapshot {
        let busy = LabSampleData.busySnapshot(now: LabClock.now(minuteOfDay: minuteOfDay))
        switch self {
        case .busy:
            return busy
        case .light:
            return LabSampleData.lightened(busy)
        case .empty:
            var snapshot = busy
            snapshot.events = []
            snapshot.reminders = []
            snapshot.doses = []
            snapshot.lastSleep = nil
            snapshot.wakeUpAlarm = nil
            return snapshot
        }
    }
}
