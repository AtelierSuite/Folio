import Planner
import SwiftUI

struct NotesUnavailableView: View {
    let status: NotesLibraryStatus

    var body: some View {
        if status == .iCloudUnavailable {
            ContentUnavailableView(
                String(localized: "Unavailable.iCloud.Title", table: "Notes"),
                systemImage: "icloud.slash",
                description: Text(String(localized: "Unavailable.iCloud.Description", table: "Notes"))
            )
        } else {
            ContentUnavailableView(
                String(localized: "Unavailable.Folder.Title", table: "Notes"),
                systemImage: "folder.badge.questionmark",
                description: Text(String(localized: "Unavailable.Folder.Description", table: "Notes"))
            )
        }
    }
}
