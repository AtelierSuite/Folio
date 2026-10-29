import SwiftUI

struct NotesStorageFooter: View {
    let isICloudSignedIn: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(String(localized: "Storage.Footer", table: "Notes"))
            if !isICloudSignedIn {
                Text(String(localized: "Storage.iCloudSignedOut", table: "Notes"))
            }
        }
    }
}
