import Planner
import SwiftUI

struct WatchCalendarAccessView: View {
    @Environment(WatchCalendarModel.self) private var model

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.title)
                    .foregroundStyle(.tint)
                Text(String(localized: "Access.Title", table: "Watch"))
                    .font(.headline)
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                if model.authorization == .notDetermined {
                    Button(String(localized: "Access.Allow", table: "Watch")) {
                        Task { await model.requestAccess() }
                    }
                    .padding(.top, 4)
                }
            }
            .multilineTextAlignment(.center)
        }
    }

    private var message: String {
        model.authorization == .notDetermined
            ? String(localized: "Access.Message", table: "Watch")
            : String(localized: "Access.Denied", table: "Watch")
    }
}
