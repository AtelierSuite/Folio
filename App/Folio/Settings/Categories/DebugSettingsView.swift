#if DEBUG
import SwiftUI

struct DebugSettingsView: View {
    var body: some View {
        Form {
            TimelineDebugSettingsSection()
            MarkdownDebugSection()
            WakeUpAlarmDebugSection()
        }
        .settingsCategoryStyle(.debug)
    }
}
#endif
