import SwiftUI

struct SampleAlert {
    struct Meeting {
        let name: String
        let systemImage: String
    }

    let title: String
    let status: String?
    let accountName: String
    let calendarName: String
    let color: Color
    let schedule: AlertSchedule
    var place: String?
    var meeting: Meeting?
    var locale = Locale(identifier: "en_US")
    var actions: [String] = ["Snooze", "Open in Folio"]
}
