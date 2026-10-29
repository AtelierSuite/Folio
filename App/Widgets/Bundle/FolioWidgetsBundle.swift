import SwiftUI
import WidgetKit

@main
struct FolioWidgetsBundle: WidgetBundle {
    var body: some Widget {
        UpNextWidget()
        TodayWidget()
        MiniMonthWidget()
        RemindersWidget()
        lockScreenWidgets
        NewEventControl()
        NewReminderControl()
        NewNoteControl()
        JoinNextMeetingControl()
    }

    @WidgetBundleBuilder
    private var lockScreenWidgets: some Widget {
        #if os(iOS)
        RemainingRemindersWidget()
        EventCountdownLiveActivity()
        #endif
    }
}
