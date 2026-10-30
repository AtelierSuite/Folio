import AppIntents
import SwiftUI
import WidgetKit

struct JoinMeetingButton: View {
    let url: URL
    var brandColor: Color?

    var body: some View {
        Button(intent: OpenURLIntent(url)) {
            Label(String(localized: "UpNext.Join", table: "Widgets"), systemImage: "video.fill")
                .font(.caption.weight(.semibold))
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .controlSize(.small)
        .tint(brandColor)
        .widgetAccentable()
    }
}
