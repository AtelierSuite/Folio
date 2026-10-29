import SwiftUI

struct NotesSplitView<Sidebar: View, Detail: View>: View {
    @ViewBuilder let sidebar: Sidebar
    @ViewBuilder let detail: Detail

    var body: some View {
        #if os(macOS)
        // A NavigationSplitView nested in the sidebar-adaptable TabView leaves an empty column on macOS.
        NavigationStack {
            HSplitView {
                sidebar
                    .frame(minWidth: 220, idealWidth: 280, maxWidth: 420)
                detail
                    .frame(minWidth: 320, maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        #else
        NavigationSplitView {
            sidebar
                .navigationSplitViewColumnWidth(min: 220, ideal: 280)
        } detail: {
            detail
        }
        #endif
    }
}
