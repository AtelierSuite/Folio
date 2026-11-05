import Planner
import SwiftUI

struct NotificationMedicationDosesView: View {
    let doses: [NotificationMedicationDetails.Dose]
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(doses) { dose in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "pills.fill")
                        .font(.title3)
                        .foregroundStyle(accentColor)
                        .frame(width: 24, height: 24)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(dose.name)
                            .font(.title3.bold())
                            .lineLimit(2)
                            .accessibilityIdentifier("NotificationDetail.Title")
                        if let summary = dose.summary {
                            Text(summary)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                                .accessibilityIdentifier("NotificationDetail.Dose")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .accessibilityElement(children: .combine)
            }
        }
    }
}
