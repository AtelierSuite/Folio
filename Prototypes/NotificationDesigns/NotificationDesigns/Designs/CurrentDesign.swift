import SwiftUI

struct CurrentDesign: View {
    let alert: SampleAlert

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(alert.color)
                .frame(width: 4)
            VStack(alignment: .leading, spacing: 6) {
                Text(alert.title)
                    .font(.headline)
                    .lineLimit(3)
                if let status = alert.status {
                    Text(status)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(alert.color)
                }
                AlertDetailLabel(text: alert.rangeText, systemImage: "clock")
                AlertPlaceLabels(alert: alert)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(16)
    }
}
