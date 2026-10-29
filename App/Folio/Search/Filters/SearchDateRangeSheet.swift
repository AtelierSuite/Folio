import SwiftUI

struct SearchDateRangeSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var dateFilter: SearchDateFilter?
    @State private var startDay = Date.now
    @State private var endDay = Calendar.current.date(byAdding: .day, value: 7, to: .now) ?? .now

    var body: some View {
        NavigationStack {
            Form {
                DatePicker(
                    String(localized: "Date.Custom.From", table: "Search"),
                    selection: $startDay,
                    displayedComponents: .date
                )
                DatePicker(
                    String(localized: "Date.Custom.Through", table: "Search"),
                    selection: $endDay,
                    in: startDay...,
                    displayedComponents: .date
                )
            }
            .formStyle(.grouped)
            .navigationTitle(String(localized: "Date.Custom.Title", table: "Search"))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        dateFilter = .custom(from: startDay, through: endDay)
                        dismiss()
                    }
                }
            }
            .onAppear(perform: loadCurrentRange)
        }
        .presentationDetents([.medium])
        #if os(macOS)
        .frame(minWidth: 360, minHeight: 200)
        #endif
    }

    private func loadCurrentRange() {
        guard case .custom(let interval) = dateFilter else { return }
        startDay = interval.start
        endDay = interval.end.addingTimeInterval(-1)
    }
}
