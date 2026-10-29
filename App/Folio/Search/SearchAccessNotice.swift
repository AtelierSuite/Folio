import Planner
import SwiftUI

struct SearchAccessNotice: View {
    @Environment(CalendarStore.self) private var store

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "calendar.badge.exclamationmark")
                .foregroundStyle(.secondary)
            Text(String(localized: "Access.Description", table: "Search"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button(String(localized: "Access.Allow", table: "Search")) {
                Task {
                    if !store.eventAuthorization.allowsReading {
                        _ = try? await store.requestFullAccessToEvents()
                    }
                    if !store.reminderAuthorization.allowsReading {
                        _ = try? await store.requestFullAccessToReminders()
                    }
                }
            }
            .buttonStyle(.bordered)
            .font(.subheadline)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}
