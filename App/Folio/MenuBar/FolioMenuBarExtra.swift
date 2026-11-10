#if os(macOS)
import Planner
import SwiftUI

struct FolioMenuBarExtra: Scene {
    let agenda: MenuBarAgenda
    let calendarStore: CalendarStore
    let destinationRequests: AppDestinationRequests
    let undoCoordinator: UndoCoordinator
    let systemTime: SystemTimeObserver
    @AppStorage(MenuBarSettings.showsItemKey) private var showsItem = true

    var body: some Scene {
        MenuBarExtra(isInserted: $showsItem) {
            MenuBarTodayView(agenda: agenda)
                .environment(\.platformCapabilities, .current)
                .environment(calendarStore)
                .environment(destinationRequests)
                .environment(undoCoordinator)
                .followsSystemTime(systemTime)
        } label: {
            MenuBarUpNextLabel(agenda: agenda)
        }
        .menuBarExtraStyle(.window)
    }
}
#endif
