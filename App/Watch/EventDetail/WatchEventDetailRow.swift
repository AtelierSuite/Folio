import SwiftUI

struct WatchEventDetailRow: View {
    let systemImage: String
    let text: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Image(systemName: systemImage)
                .foregroundStyle(.secondary)
            Text(text)
        }
        .font(.footnote)
    }
}
