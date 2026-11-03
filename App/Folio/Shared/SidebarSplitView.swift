import SwiftUI

struct SidebarSplitView<Sidebar: View, Detail: View>: View {
    @ViewBuilder let sidebar: Sidebar
    @ViewBuilder let detail: Detail

    var body: some View {
        #if os(macOS)
        // A NavigationSplitView nested in the sidebar-adaptable TabView leaves an empty column on macOS.
        // HSplitView ignores idealWidth; giving the detail layout priority opens the sidebar at its minimum width.
        NavigationStack {
            HSplitView {
                sidebar
                    .frame(minWidth: 200, idealWidth: 200, maxWidth: 420)
                detail
                    .frame(minWidth: 320, maxWidth: .infinity, maxHeight: .infinity)
                    .layoutPriority(1)
            }
        }
        #else
        NavigationSplitView {
            sidebar
                .navigationSplitViewColumnWidth(min: 200, ideal: 240)
        } detail: {
            detail
        }
        #endif
    }
}
