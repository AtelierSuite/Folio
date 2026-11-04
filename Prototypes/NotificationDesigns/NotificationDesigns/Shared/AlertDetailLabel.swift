import SwiftUI

struct AlertDetailLabel: View {
    let text: String
    let systemImage: String

    var body: some View {
        Label {
            Text(text)
                .lineLimit(2)
        } icon: {
            Image(systemName: systemImage)
                .foregroundStyle(.secondary)
        }
        .font(.subheadline)
    }
}

struct AlertPlaceLabels: View {
    let alert: SampleAlert

    var body: some View {
        if let place = alert.place {
            AlertDetailLabel(text: place, systemImage: "mappin.and.ellipse")
        }
        if let meeting = alert.meeting {
            AlertDetailLabel(text: meeting.name, systemImage: meeting.systemImage)
        }
    }
}
