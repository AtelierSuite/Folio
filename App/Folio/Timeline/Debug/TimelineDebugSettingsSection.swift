#if DEBUG
import SwiftUI

struct TimelineDebugSettingsSection: View {
    #if os(macOS)
    @State private var isShowingTimeline = false
    #endif

    private var title: String {
        String(localized: "Debug.SettingsRow", table: "Timeline")
    }

    var body: some View {
        Section {
            #if os(macOS)
            Button(title) {
                isShowingTimeline = true
            }
            .sheet(isPresented: $isShowingTimeline) {
                NavigationStack {
                    TimelineDebugView()
                        .toolbar {
                            Button(String(localized: "Debug.Done", table: "Timeline")) {
                                isShowingTimeline = false
                            }
                        }
                }
                .frame(minWidth: 900, minHeight: 640)
            }
            #else
            NavigationLink(title) {
                TimelineDebugView()
            }
            #endif
        }
    }
}
#endif
