import SwiftUI

struct WatchTimelineEmptyView: View {
    var body: some View {
        ContentUnavailableView {
            Label(String(localized: "Timeline.Empty.Title", table: "Watch"), systemImage: "calendar")
        } description: {
            Text(String(localized: "Timeline.Empty.Message", table: "Watch"))
        }
    }
}
