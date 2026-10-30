#if DEBUG
import SwiftUI

struct DebugSettingsView: View {
    var body: some View {
        Form {
            TimelineDebugSettingsSection()
            MarkdownDebugSection()
        }
        .settingsCategoryStyle(.debug)
    }
}
#endif
