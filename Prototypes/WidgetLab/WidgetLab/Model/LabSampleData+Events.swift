import SwiftUI

extension LabSampleData {
    private static let videoCall = LabMeeting(provider: "Video call", brandColor: .blue)

    static let todayEvents = [
        LabEvent(title: "Standup", start: LabClock.date(hour: 9), end: LabClock.date(hour: 9, minute: 30), tint: .blue, meeting: videoCall),
        LabEvent(
            title: "Design review",
            start: LabClock.date(hour: 15, minute: 30),
            end: LabClock.date(hour: 16),
            tint: .purple,
            meeting: videoCall,
            attendees: [
                LabAttendee(name: "Mika Sato", response: .accepted),
                LabAttendee(name: "Jon Reyes", response: .accepted),
                LabAttendee(name: "Lena Vogel", response: .tentative),
                LabAttendee(name: "Tao Lin", response: .noReply)
            ],
            note: LabNote(
                title: "Widget review",
                summary: "Decide which two widget ideas move forward this cycle.",
                checklist: [
                    LabChecklistItem(text: "Share the contact sheet", isDone: true),
                    LabChecklistItem(text: "Bring lock screen options", isDone: false),
                    LabChecklistItem(text: "Agree on the data budget", isDone: false),
                    LabChecklistItem(text: "Name an owner for each idea", isDone: false)
                ]
            )
        ),
        LabEvent(title: "Lunch with Mika", start: LabClock.date(hour: 12), end: LabClock.date(hour: 13), tint: .green, location: "Ebisu"),
        LabEvent(title: "Dentist", start: LabClock.date(hour: 14, minute: 30), end: LabClock.date(hour: 15, minute: 15), tint: .red, location: "Daikanyama Dental", travelMinutes: 25),
        LabEvent(title: "Sprint planning", start: LabClock.date(hour: 16), end: LabClock.date(hour: 17), tint: .blue, meeting: videoCall),
        LabEvent(title: "Vendor call", start: LabClock.date(hour: 16, minute: 30), end: LabClock.date(hour: 17), tint: .orange, meeting: videoCall),
        LabEvent(title: "Quarterly sync", start: LabClock.date(hour: 17, minute: 30), end: LabClock.date(hour: 18), tint: .teal, awaitsMyResponse: true),
        LabEvent(title: "Family dinner", start: LabClock.date(hour: 19), end: LabClock.date(hour: 21), tint: .green, location: "Nakameguro", travelMinutes: 20)
    ]

    static let weekEvents = [
        LabEvent(title: "Farmers market", start: LabClock.date(dayOffset: 1, hour: 10, minute: 30), end: LabClock.date(dayOffset: 1, hour: 12), tint: .green, location: "Aoyama", travelMinutes: 30),
        LabEvent(title: "Team offsite prep", start: LabClock.date(dayOffset: 3, hour: 10), end: LabClock.date(dayOffset: 3, hour: 12), tint: .blue, awaitsMyResponse: true),
        LabEvent(title: "1:1 with Jon", start: LabClock.date(dayOffset: 3, hour: 14), end: LabClock.date(dayOffset: 3, hour: 15), tint: .purple),
        LabEvent(title: "Roadmap workshop", start: LabClock.date(dayOffset: 4, hour: 13), end: LabClock.date(dayOffset: 4, hour: 15), tint: .blue),
        LabEvent(title: "Yoga", start: LabClock.date(dayOffset: 5, hour: 18), end: LabClock.date(dayOffset: 5, hour: 19), tint: .teal),
        LabEvent(title: "Client workshop", start: LabClock.date(dayOffset: 6, hour: 9), end: LabClock.date(dayOffset: 6, hour: 13), tint: .orange),
        LabEvent(title: "Release review", start: LabClock.date(dayOffset: 6, hour: 14), end: LabClock.date(dayOffset: 6, hour: 18), tint: .purple)
    ]

    static let horizonEvents = [
        LabEvent(title: "Mika's birthday", start: LabClock.date(dayOffset: 3), end: LabClock.date(dayOffset: 4), tint: .pink, isAllDay: true),
        LabEvent(title: "Kyoto trip", start: LabClock.date(dayOffset: 36), end: LabClock.date(dayOffset: 38), tint: .orange, isAllDay: true),
        LabEvent(title: "Passport renewal", start: LabClock.date(dayOffset: 134), end: LabClock.date(dayOffset: 135), tint: .red, isAllDay: true),
        LabEvent(title: "Summer in Hokkaido", start: LabClock.date(dayOffset: 280), end: LabClock.date(dayOffset: 287), tint: .teal, isAllDay: true)
    ]
}
