import Planner

extension CalendarTimelineView {
    /// Screenshots start early enough to show the night's sleep and an early alarm, or the working day where there
    /// is no sleep to show.
    static var defaultInitialHour: Double {
        #if DEBUG
        if ScreenshotStage.requested != nil {
            return PlatformCapabilities.current.supports(.sleep) ? 4.5 : 7.5
        }
        #endif
        return 8
    }
}
