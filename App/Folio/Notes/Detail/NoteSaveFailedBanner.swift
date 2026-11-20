import SwiftUI

struct NoteSaveFailedBanner: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
            VStack(alignment: .leading, spacing: 2) {
                Text(String(localized: "SaveFailed.Title", table: "Notes"))
                    .font(.subheadline.weight(.semibold))
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Button(String(localized: "SaveFailed.Retry", table: "Notes"), action: onRetry)
                .buttonStyle(.glass)
                .controlSize(.small)
                .accessibilityIdentifier("NoteSaveFailedBanner.Retry")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.bar)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("NoteSaveFailedBanner")
    }
}
