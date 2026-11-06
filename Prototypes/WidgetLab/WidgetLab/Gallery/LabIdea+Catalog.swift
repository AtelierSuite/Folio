import SwiftUI

extension LabIdea {
    static let catalog: [LabIdea] = [
        LabIdea(number: 1, name: "Leave By", summary: "Counts down to walking out the door.", dataNeeded: "Needs travel estimates and hourly rain in the snapshot.", widgets: [
            LabWidgetSpec(.small, LeaveBySmallView.init), LabWidgetSpec(.medium, LeaveByMediumView.init),
            LabWidgetSpec(.circular, LeaveByCircularView.init), LabWidgetSpec(.rectangular, LeaveByRectangularView.init)
        ]),
        LabIdea(number: 2, name: "Free Gaps", summary: "Shows open time. Travel counts as busy.", dataNeeded: "Events only, so it fits today's snapshot.", widgets: [
            LabWidgetSpec(.small, FreeGapsSmallView.init), LabWidgetSpec(.medium, FreeGapsMediumView.init),
            LabWidgetSpec(.rectangular, FreeGapsRectangularView.init), LabWidgetSpec(.inline, FreeGapsInlineView.init)
        ]),
        LabIdea(number: 3, name: "Day Ring", summary: "24 hours with midnight at the bottom.", dataNeeded: "Needs sleep and doses cached in the App Group.", widgets: [
            LabWidgetSpec(.small, DayRingSmallView.init), LabWidgetSpec(.medium, DayRingMediumView.init),
            LabWidgetSpec(.circular, DayRingCircularView.init)
        ]),
        LabIdea(number: 4, name: "Week Load", summary: "How heavy each of the next seven days is.", dataNeeded: "Needs a 7 day interval and holidays.", widgets: [
            LabWidgetSpec(.medium, WeekLoadMediumView.init), LabWidgetSpec(.large, WeekLoadLargeView.init)
        ]),
        LabIdea(number: 5, name: "Meeting Prep Card", summary: "Next meeting with its linked note.", dataNeeded: "Needs linked notes and attendees in the snapshot.", widgets: [
            LabWidgetSpec(.medium, MeetingPrepMediumView.init), LabWidgetSpec(.large, MeetingPrepLargeView.init)
        ]),
        LabIdea(number: 6, name: "Day Shift", summary: "Changes with the time of day. Move the slider.", dataNeeded: "Needs the wake-up alarm in the snapshot.", widgets: [
            LabWidgetSpec(.small, DayShiftSmallView.init), LabWidgetSpec(.medium, DayShiftMediumView.init)
        ]),
        LabIdea(number: 7, name: "Horizon", summary: "A logarithmic line out to a year.", dataNeeded: "Needs a year of all-day events and holidays.", widgets: [
            LabWidgetSpec(.medium, HorizonMediumView.init), LabWidgetSpec(.large, HorizonLargeView.init)
        ]),
        LabIdea(number: 8, name: "Needs Attention", summary: "Invitations, conflicts and overdue reminders.", dataNeeded: "Needs participant status in the snapshot.", widgets: [
            LabWidgetSpec(.medium, NeedsAttentionMediumView.init), LabWidgetSpec(.large, NeedsAttentionLargeView.init),
            LabWidgetSpec(.circular, NeedsAttentionCircularView.init)
        ]),
        LabIdea(number: 9, name: "Daily Almanac", summary: "A tear-off page for today.", dataNeeded: "Needs holidays, and sun times from the weather cache.", widgets: [
            LabWidgetSpec(.small, AlmanacSmallView.init), LabWidgetSpec(.medium, AlmanacMediumView.init)
        ]),
        LabIdea(number: 10, name: "Dose Rail", summary: "Today's doses. View only.", dataNeeded: "Needs doses cached in the App Group.", widgets: [
            LabWidgetSpec(.small, DoseRailSmallView.init), LabWidgetSpec(.medium, DoseRailMediumView.init),
            LabWidgetSpec(.rectangular, DoseRailRectangularView.init)
        ])
    ]
}
