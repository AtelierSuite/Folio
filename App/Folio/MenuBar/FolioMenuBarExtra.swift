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
        MenuBarExtra(isInserted: isInserted) {
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

    // MenuBarExtra writes isInserted back on every scene update; writing UserDefaults each time
    // re-renders every @AppStorage view and the scene again, looping forever.
    private var isInserted: Binding<Bool> {
        Binding {
            showsItem
        } set: { newValue in
            if newValue != showsItem {
                showsItem = newValue
            }
        }
    }
}
#endif
