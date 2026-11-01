import SwiftUI

struct AlarmSettingsView: View {
    var body: some View {
        Form {
            WakeUpAlarmSection()
            LeaveAlarmSection()
        }
        .settingsCategoryStyle(.alarms)
    }
}
