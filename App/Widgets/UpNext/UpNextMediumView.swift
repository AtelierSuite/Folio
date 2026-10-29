import Planner
import SwiftUI

struct UpNextMediumView: View {
    let upNext: WidgetUpNext?

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            UpNextSmallView(upNext: upNext)
            if let upNext {
                VStack(alignment: .leading, spacing: 6) {
                    Text(String(localized: "UpNext.Later", table: "Widgets"))
                        .font(.caption2.weight(.bold))
                        .textCase(.uppercase)
                        .foregroundStyle(.secondary)
                    if upNext.following.isEmpty {
                        WidgetEmptyText(text: String(localized: "UpNext.NothingElse", table: "Widgets"))
                    } else {
                        ForEach(upNext.following) { event in
                            WidgetEventRow(event: event)
                        }
                        Spacer(minLength: 0)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
    }
}
