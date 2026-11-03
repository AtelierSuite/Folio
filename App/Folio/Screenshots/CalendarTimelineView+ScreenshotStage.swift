extension CalendarTimelineView {
    /// Screenshots start earlier in the day, so the night's sleep and an early alarm are in view.
    static var defaultInitialHour: Double {
        #if DEBUG
        if ScreenshotStage.requested != nil { return 4.5 }
        #endif
        return 8
    }
}
