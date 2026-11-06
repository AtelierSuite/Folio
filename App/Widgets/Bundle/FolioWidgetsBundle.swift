import SwiftUI
import WidgetKit

@main
struct FolioWidgetsBundle: WidgetBundle {
    var body: some Widget {
        UpNextWidget()
        TodayWidget()
        HourlyWidget()
        MiniMonthWidget()
        RemindersWidget()
        DayLoadWidget()
        DayShiftWidget()
        EventNotesWidget()
        InboxWidget()
        lockScreenWidgets
        NewEventControl()
        NewReminderControl()
        NewNoteControl()
        JoinNextMeetingControl()
        OpenTodayControl()
    }

    @WidgetBundleBuilder
    private var lockScreenWidgets: some Widget {
        #if os(iOS)
        RemainingRemindersWidget()
        LeaveByWidget()
        EventCountdownLiveActivity()
        #endif
        #if canImport(AlarmKit) && os(iOS)
        FolioAlarmLiveActivity()
        #endif
    }
}
