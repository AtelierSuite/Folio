import Planner
import SwiftUI

struct HolidayRefreshButton: View {
    @AppStorage(DayHighlightSettings.holidaysRefreshedAtKey, store: AppGroup.userDefaults)
    private var refreshedAt = 0.0
    @State private var isRefreshing = false
    @State private var isShowingFailure = false
    @State private var lastUpdated: Date?
    let source: HolidaySource

    var body: some View {
        row
            .task(id: source) {
                lastUpdated = HolidayRepository().lastUpdated(source)
            }
            .alert(String(localized: "Settings.RefreshFailed", table: "Holidays"), isPresented: $isShowingFailure) {
            } message: {
                Text(String(localized: "Settings.RefreshFailedMessage", table: "Holidays"))
            }
    }

#if os(macOS)
    private var row: some View {
        LabeledContent(String(localized: "Settings.LastUpdated", table: "Holidays")) {
            HStack {
                if let lastUpdated {
                    Text(lastUpdated, format: .dateTime.year().month().day().hour().minute())
                } else {
                    Text(String(localized: "Settings.Never", table: "Holidays"))
                }
                if isRefreshing {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Button(String(localized: "Settings.RefreshNow", table: "Holidays"), action: refresh)
                        .accessibilityIdentifier("RefreshHolidaysButton")
                }
            }
        }
    }
#else
    private var row: some View {
        Button(action: refresh) {
            HStack {
                Text(String(localized: "Settings.Refresh", table: "Holidays"))
                Spacer()
                if isRefreshing {
                    ProgressView()
                } else if let lastUpdated {
                    Text(lastUpdated, format: .dateTime.year().month().day().hour().minute())
                        .foregroundStyle(Color.secondary)
                }
            }
        }
        .disabled(isRefreshing)
        .accessibilityIdentifier("RefreshHolidaysButton")
    }
#endif

    private func refresh() {
        isRefreshing = true
        Task {
            let repository = HolidayRepository()
            do {
                try await repository.refresh(source)
                refreshedAt = Date.now.timeIntervalSince1970
            } catch {
                isShowingFailure = true
            }
            lastUpdated = repository.lastUpdated(source)
            isRefreshing = false
        }
    }
}
